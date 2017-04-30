#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Box Plots", tabName = "boxplot", icon = icon("dashboard")),
      menuItem("Histograms", tabName = "histogram", icon = icon("dashboard")),
      menuItem("Scatter Plots", tabName = "scatter", icon = icon("dashboard")),
      menuItem("Crosstabs, KPIs, Parameters", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barcharts, Table Calculations", tabName = "barchart", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),    
    tabItems(
      # Begin Box Plots tab content.
      tabItem(tabName = "boxplot",
              tabsetPanel(
                tabPanel("Data",  
                         radioButtons("rb5", "Get Data From:",
                                      c("SQL" = "SQL")),
                         uiOutput("boxplotRegions"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                         actionButton(inputId = "click5",  label = "Click Here for Data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("boxplotData1")
                ),
                tabPanel("Box Plot", 
                         sliderInput("boxCostRange1", "Cost Range:",
                                     min = 0, max = 1000000000, 
                                     value = c(min(globals$Cost), max(globals$Cost))),
                         plotlyOutput("boxplotPlot1", height=500))
              )
      ),
      # End Box Plots tab content.
      # Begin Histogram tab content.
      tabItem(tabName = "histogram",
              tabsetPanel(
                tabPanel("Data",  
                         radioButtons("rb4", "Get Data From:",
                                      c("SQL" = "SQL")),
                         actionButton(inputId = "click4",  label = "Click Here for Data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("histogramData1")
                ),
                tabPanel("Histogram", plotlyOutput("histogramPlot1", height=1000))
              )
      ),
      # End Histograms tab content.
      # Begin Scatter Plots tab content.
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         radioButtons("rb3", "Get Data From:",
                                      c("SQL" = "SQL")),
                         uiOutput("scatterStates"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                         actionButton(inputId = "click3",  label = "Click Here for Data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Scatter Plot", plotlyOutput("scatterPlot1", height=1000))
              )
      ),
      # End Scatter Plots tab content.
      # Begin Crosstab tab content.
      tabItem(tabName = "crosstab",
        tabsetPanel(
            tabPanel("Data",  
                     radioButtons("rb1", "Get Data From:",
                                  c("SQL" = "SQL")),
              sliderInput("KPI1", "KPI_Low:", 
                          min = 0, max = 3.5,  value = .1),
              sliderInput("KPI2", "KPI_Medium:", 
                          min = 3.5, max = 5,  value = .2),
              actionButton(inputId = "click1",  label = "Click Here for Data"),
              hr(), # Add space after button.
              DT::dataTableOutput("data1")
            ),
            tabPanel("Crosstab","Text represents the cost per Category for each State, The KPI represents the Library Visits/Population according to the user inputed parameters.", plotOutput("plot1", height=1000))
          )
        ),
      # End Crosstab tab content.
      # Begin Barchart tab content.
      tabItem(tabName = "barchart",
        tabsetPanel(
          tabPanel("Data",  
             radioButtons("rb2", "Get Data From:",
                 c("SQL" = "SQL")),
             uiOutput("regions2"),
             actionButton(inputId = "click2",  label = "Click Here for Data"),
             hr(), # Add space after button.
             'Here is data for the "Librarians per State Population" tab',
             hr(),
             DT::dataTableOutput("barchartData1"),
             hr(),
             'Here is data for the "Young Adult Program Audiences vs 9-12 Grade Enrollment" tab',
             hr(),
             DT::dataTableOutput("barchartData2")
          ),
          tabPanel("Librarians per State Population", "x= State, y = Librarians, fill = State Population / Librarians", plotOutput("barchartPlot1", height=1500)),
          tabPanel("Young Adult Program Audiences vs 9-12 Grade Enrollment", "Blue = Audience of over 40k, Red = Audience less than 40k, Black line = Audience Median", plotOutput("barchartPlot2", height=700) )
        )
      )
      # End Barchart tab content.
    )
  )
)

