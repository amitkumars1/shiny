library(shiny)
## Create the shiny user interface
shinyUI(pageWithSidebar(
        ## Main title
        titlePanel("US export Sales data for Soybean and Corn"),
        ## side panel for the hasrate input
        sidebarPanel(
                helpText("This plot charts time series for US Soybean and Corn Export Fields"),
                ## hashrate input by user (must bre greater then 0)
                #                 numericInput("comdty", ":", 0,
                #                              min = 0),
                selectInput("Commodity",
                            label = NULL,
                            choices = list("Soybean", "Corn"),
                            selected = "Soybean"),
                selectInput("Field",
                            label = NULL,
                            choices = list("WeeklyExports", "AccumulatedExports", "OutStandingSales", "totalCommitment"),
                            selected = "WeeklyExports"),
                dateRangeInput("dates", label = h3("Date range"),start = "2013-01-01",end = "2014-10-16",
                               min = "1995-01-01", max = "2014-10-16"),
                
                selectInput("plottype",
                            label = NULL,
                            choices = list("line", "barplot"),
                            selected = "line"),
                ## Submit button to server.R
                submitButton("Submit"),
                p("start date should be atleast a week before end date"),
                p("Documentation:", a("About", href = "http://apps.fas.usda.gov/export-sales/esrd1.html")),
                p("These reports form an important basis for price movements in agricultural commodities markets" ),
                p("Data is downloaded directly from the USDA repositories, please wait for 30 seconds for the plots to appear" )
                
        ),
        
        mainPanel(
                tabsetPanel(
                        tabPanel("Plot", plotOutput("plot"))
                        
                        
                )
        )
)
)