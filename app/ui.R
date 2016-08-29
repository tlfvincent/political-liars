library(shiny)
library(shinydashboard)
library(DT)
library(d3radarR)
library(rjson)
library(tm)
library(wordcloud)

json_file <- 'politifact_statements.txt'
truth_data <- fromJSON(file=json_file)
entities <- names(sort(unlist(lapply(truth_data, length)), decreasing=TRUE))

# Simple header -----------------------------------------------------------

header <- dashboardHeader(title="Truth-O-Meter")

# No sidebar --------------------------------------------------------------

sidebar <- dashboardSidebar(disable = TRUE)

# Body --------------------------------------------------------------------

body <- dashboardBody(
    # Also add some custom CSS to make the title background area the same
    # color as the rest of the header.
    tags$head(tags$style(HTML('
      .skin-blue .main-header .logo {
        background-color: #3c8dbc;
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 24px;
      }
      .skin-blue .main-header .logo:hover {
        background-color: #3c8dbc;
      }
    '))),

    # Boxes need to be put in a row (or column)
    fluidRow(
        # add selection box and image of first selection
        box(width=1, uiOutput("image_choice_1")),
        box(status = "primary",
            width=4,
            selectizeInput('choice_1',
                            label = NULL,
                            choices = entities,
                            options = list(create = TRUE,
                                           maxItems = 1,
                                           placeholder = 'select 1 political entity')
            )
        ),
        box(width=1, 'VS.'),
        # add selection box and image of second selection
        box(status = "primary",
            width=4,
            selectizeInput('choice_2',
                            label = NULL,
                            choices = entities,
                            options = list(create = TRUE,
                                           maxItems = 1,
                                           placeholder = 'select 1 political entity')
            )
        ),
        box(width=1, uiOutput("image_choice_2"))
    ),

    # plot spider chart of statements truth, and wordcloud of statements
    fluidRow(
        box(width=4,
            plotOutput('wc_choice_1')
        ),
        box(width=4,
            d3radarOutput("ResultPlot")
        ),
        box(width=4,
            plotOutput('wc_choice_2')
        )
    ),

    # show breakdown of statements in table
    fluidRow(
        box(width=12,
            dataTableOutput('ResultTable')
        )
    )


)


# Setup Shiny app UI components -------------------------------------------
ui <- dashboardPage(header, sidebar, body, skin="blue")
