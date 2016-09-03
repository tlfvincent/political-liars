## load required libraries
library(rjson)
library(pheatmap)
library(plyr)
library(ggplot2)
library(reshape2)
library(grid)
library(gridExtra)

### Taken from http://stackoverflow.com/questions/15505607/diagonal-labels-orientation-on-x-axis-in-heatmaps
## Edit body of pheatmap:::draw_colnames, customizing it to your liking
draw_colnames_45 <- function (coln, ...) {
    m = length(coln)
    x = (1:m)/m - 1/2/m
    grid.text(coln, x = x, y = unit(0.96, "npc"), vjust = .5, 
        hjust = 1, rot = 45, gp = gpar(...)) ## Was 'hjust=0' and 'rot=270'
}

## 'Overwrite' default draw_colnames with your own version 
assignInNamespace(x="draw_colnames", value="draw_colnames_45",
ns=asNamespace("pheatmap"))
###

## read in politifact data
json_file <- './app/politifact_statements.txt'
truth_data <- fromJSON(file=json_file)

## find number of comments per indivdual and filter to top 20
comment_count <- unlist(lapply(truth_data, function(x) length(x)))
relevant <- c()
for(i in 1:length(comment_count)){
    if(comment_count[i] >=20) {
        relevant <- c(relevant, names(comment_count)[i])
    }
}

## filter data to 20 individuals with most comments
truth_data <- truth_data[relevant]

## plot heatmap of comment types per individual
df <- ldply(lapply(truth_data, function(x) table(x)), data.frame)
df <- acast(df, .id~x, value.var='Freq', fill=0)
df <- apply(df, 1, function(x) x/sum(x))

## reorder columns in a sensible way
col_order <- c('True', 'Mostly True', 'Half-True', 'Mostly False',
               'False', 'Pants on Fire!', 'No Flip', 'Half Flip',
               'Full Flop')
df <- t(df)[, col_order]

## plot data as heatmap
pheatmap(df, cellheight=15, cellwidth=25, cluster_cols=FALSE,
         main='Proportion of true and false comments made by entities',
         color = colorRampPalette(c("navy", "white", "firebrick3"))(50))

## plot proportion of false comments made by each entity
df_false <- apply(df[, c('Mostly False', 'False', 'Pants on Fire!')], 1, sum)
df_false <- melt(df_false)
df_false$entity <- row.names(df_false)

## plot proportion of false comments made by each entity
df_true <- apply(df[, c('True', 'Mostly True', 'Half-True')], 1, sum)
df_true <- melt(df_true)
df_true$entity <- row.names(df_true)

### solution taken from http://stackoverflow.com/questions/18265941/two-horizontal-bar-charts-with-shared-axis-in-ggplot2-similar-to-population-pyr
dat <- df_false
dat$true_value <- df_true$value
colnames(dat) <- c('false_prop', 'entity', 'truth_prop')
dat$entity <- factor(dat$entity, levels = dat$entity[order(dat$false_prop)])

## generate middle grid
g.mid <- ggplot(dat, aes(x=1, y=entity)) + 
  geom_text(aes(label=entity)) +
  geom_segment(aes(x=0.94, xend=0.96, yend=entity)) +
  geom_segment(aes(x=1.04, xend=1.065, yend=entity)) +
  ggtitle("") +
  ylab(NULL) +
  scale_x_continuous(expand=c(0,0), limits=c(0.94,1.065))+
  theme(axis.title=element_blank(),
        panel.grid=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        axis.text.x=element_text(color=NA),
        axis.ticks.x=element_line(color=NA),
        plot.margin = unit(c(1,-1,1,-1), "mm"))

## generate left grid showing proportion of false statements
g1 <- ggplot(data = dat, aes(x=entity, y=false_prop)) +
  geom_bar(stat='identity', fill="firebrick3") +
  ggtitle("Proportion of false comments") +
  theme(axis.title.x = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        plot.margin = unit(c(1,-1,1,0), "mm")) +
  scale_y_reverse() + coord_flip()

## generate left grid showing proportion of true statements
g2 <- ggplot(data = dat, aes(x=entity, y=truth_prop)) +
  xlab(NULL)+
  geom_bar(stat='identity', fill="steelblue") +
  ggtitle("Proportion of true comments") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(), 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        plot.margin = unit(c(1,0,1,-1), "mm")) +
  coord_flip()


gg1 <- ggplot_gtable(ggplot_build(g1))
gg2 <- ggplot_gtable(ggplot_build(g2))
gg.mid <- ggplot_gtable(ggplot_build(g.mid))
grid.arrange(gg1,gg.mid,gg2,ncol=3,widths=c(4/10,2/10,4/10))


