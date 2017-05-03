#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(skin = "black",
  dashboardHeader(title = "The Library System of the United States", titleWidth = 400
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("dashboard")),
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
      # Begin Home Page tab content.
      tabItem(tabName = "home", 
              h1('Welcome to our Shiny application!'),
              img(src='books_image.png')
      ),
      
      # Begin Box Plots tab content.
      tabItem(tabName = "boxplot",
              tabsetPanel(
                tabPanel("Data",  
                         radioButtons("rb5", "Get Data From:",
                                      c("SQL" = "SQL")),
                         uiOutput("boxplotRegions"),
                         actionButton(inputId = "click5",  label = "Click Here for Data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("boxplotData1"),
                         h3('Here is an explanation of a simple boxplot.'),
                         img(src='boxplot_explanation.png')
                ),
                tabPanel("Cost Range per Category",
                         h4('This boxplot shows the minimum, maximum, first quartile, third quartile, and median of the "Cost" values for each expenditure, including Digital Collection Expenditures, Print Collection Expenditures, Other Expenditures, and Total Expenditures. The user may select the "Cost Range" that they would like to see. \n This is interesting because you can see how many states are outliers in spending on Digital and Print Expenditures.'),
                         sliderInput("boxCostRange1", "Cost Range:",
                                     min = 0, max = 100000000, 
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
                tabPanel("Librarian Histogram","Shows the distribution of counts for Librarians per State. This is interesting because you can see the overall trend of lot of states having relatively little Librarians (>300), while one state, New York, has almost a thousand more librarians than the second highest state, CA, created a gap in the histogram.",
                         plotlyOutput("histogramPlot1", height=700))
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
                tabPanel("Library Visits vs Median Family Income","Compares library visits with Median Family Income in 2015. This is interesting because it shows a trend that richer states have more library visits. We were surprised by this because libraries provide many services for free that would benefit low income families.", plotlyOutput("scatterPlot1", height=700))
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
            tabPanel("Cost per Category for Each State","Text represents the cost per Category for each State, The KPI represents the Library Visits/Population according to the user inputed parameters. This is interesting because you can see that Texas has some of the highest library costs in the country, but still has a relatively low number of visitors per service population.", plotOutput("plot1", height=700))
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
          tabPanel("Librarians per State Population", "x= State, y = Librarians, fill = State Population / Librarians. This is interesting because you can see that GA has a relatively low number of overall librarians, but has by far the highest ratio of librarians per citizen.", plotOutput("barchartPlot1", height=700)),
          tabPanel("Library Hours Open per State", "Blue = Hours Open over 1,000,000, Red = Hours Open less than 1,000,000, Black line = 9-12th Grade Enrollment. This is interesting because, generally speaking, the states with the highest hours open have the highest high school enrollment.", plotOutput("barchartPlot2", height=700) )
        )
      )
      # End Barchart tab content.
    )
  )
)

