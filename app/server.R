library(shiny)
library(htmlwidgets)
library(d3radarR)
library(shinydashboard)
library(ggplot2)
library(rjson)
library(wordcloud)
library(tm)

top_words <- 25

json_file <- 'politifact_statements.txt'
truth_data <- fromJSON(file=json_file)

json_file_text <- 'politifact_statements_text.txt'
truth_data_text <- fromJSON(file=json_file_text)

image_source <- read.csv('politifact_image_source.csv')

# Define a server for the Shiny app
server <- function(input, output) {

  check_values <- reactive({
      if(identical(input$choice_1, input$choice_2)) {
        return(FALSE)
      }
    else if(input$choice_1 == '' | input$choice_2 == '') {
        return(FALSE)
    }
    else{
        return(TRUE)
    }
  })

  extract_values <- reactive({
      statements <- c('True', 'Mostly True', 'Half-True',
                      'Mostly False', 'False', 'Pants on Fire!',
                      'No Flip', 'Half Flip', 'Full Flop')
      statement_choice_1 <- c()
      statement_choice_1_percent <- c()
      statement_choice_2 <- c()
      statement_choice_2_percent <- c()
      for(s in 1:length(statements)) {
        statement_choice_1[s] <- length(which(truth_data[[input$choice_1]] == statements[s]))
        statement_choice_1_percent <- round((statement_choice_1 / sum(statement_choice_1)), 2)
        statement_choice_2[s] <- length(which(truth_data[[input$choice_2]] == statements[s]))
        statement_choice_2_percent <- round((statement_choice_2 / sum(statement_choice_2)), 2)
      }
      df <- as.data.frame(rbind(statement_choice_1,
                                statement_choice_1_percent,
                                statement_choice_2,
                                statement_choice_2_percent))
      colnames(df) <- statements
      row.names(df) <- c(paste('1.', input$choice_1),
                         ' ',
                         paste('2.', input$choice_2),
                         '')
      return(df)
  })

  generate_radarchart <- reactive({
      df <- extract_values()
      statements <- c('True', 'Mostly True', 'Half-True',
                'Mostly False', 'False', 'Pants on Fire!',
                'No Flip', 'Half Flip', 'Full Flop')
      test <- vector('list', 2)
      test[[1]]$key <- input$choice_1
      test[[2]]$key <- input$choice_2
      test[[1]]$values <- vector('list', 8)
      test[[2]]$values <- vector('list', 8)
      for(i in 1:8) {
        test[[1]]$values[[i]]$axis <- statements[i]
        test[[1]]$values[[i]]$value <- df[2, i]
        test[[2]]$values[[i]]$axis <- statements[i]
        test[[2]]$values[[i]]$value <- df[4, i]
      }

      return(test)
    })

  output$wc_choice_1 <- renderPlot({
      present <- truth_data_text[[input$choice_1]] %in% stopwords("SMART")
      m <- truth_data_text[[input$choice_1]][which(present=='FALSE')]
      m <- table(m)
      v <- sort(m, decreasing=TRUE)
      d <- data.frame(word = names(v), freq=v)
      d <- d[1:min(top_words, nrow(d)), ]
      wordcloud(d$word, d$freq)
  })

  output$wc_choice_2 <- renderPlot({
      present <- truth_data_text[[input$choice_2]] %in% stopwords("SMART")
      m <- truth_data_text[[input$choice_2]][which(present=='FALSE')]
      m <- table(m)
      v <- sort(m, decreasing=TRUE)
      d <- data.frame(word = names(v), freq=v)
      d <- d[1:min(top_words, nrow(d)), ]
      wordcloud(d$word, d$freq)
  })

  output$image_choice_1 <- renderUI({
    outfile <- as.vector(image_source[which(image_source[, 1] == input$choice_1), 2])
    tags$img(src=outfile)
  })

  output$image_choice_2 <- renderUI({
    outfile <- as.vector(image_source[which(image_source[, 1] == input$choice_2), 2])
    tags$img(src=outfile)
  })

  output$ResultPlot <- renderD3radar({
      df_radar <- generate_radarchart()
      d3radar(df_radar, width='300px', height='300px')

  })

  output$ResultTable <- renderDataTable(
      datatable(extract_values(),
                options = list(paging = FALSE,
                               searching = FALSE))
  )

}