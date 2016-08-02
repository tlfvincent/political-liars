ROM r-base:latest

MAINTAINER Thomas Vincent "tlfvincent@gmail.com"

## Expose port for shiny app
EXPOSE 3838

RUN apt-get update && apt-get install -y -t unstable \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev/unstable

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb


RUN apt-get install -y -t unstable \
    littler \
    r-cran-littler && \
    echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r && \
    R -e "install.packages(c('shiny', 'rmarkdown', 'devtools', 'rjson', 'ggplot2', 'wordcloud', 'shinydashboard', 'tm', 'data.table'), repos='https://cran.rstudio.com/')" && \
    R -e "install.packages(c('htmlwidgets', 'DT'))" && \
    R -e "devtools::install_github('timelyportfolio/d3radarR')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/


## Copy app and config files to shiny server directory
COPY /app/* /srv/shiny-server/app/
COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]