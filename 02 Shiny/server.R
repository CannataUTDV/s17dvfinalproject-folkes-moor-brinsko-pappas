# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(leaflet)
require(plotly)
require(lubridate)

online0 = TRUE
library(plotly)

# The following query is for the select lists. 
if(online0) {
  regions = query(
    data.world(propsfile = "www/.data.world"),
    dataset="hsfolkes/s-17-dv-final-project", type="sql",
    query="select distinct State as R
  from states
    order by 1"
  ) # %>% View()
} else {
}
region_list <- as.list(regions$R)
region_list <- append(list("All" = "All"), region_list)
region_list5 <- region_list


############################### Start shinyServer Function ####################

shinyServer(function(input, output) {   
  # These widgets are for the Box Plots tab.
  online5 = reactive({input$rb5})
  output$boxplotRegions <- renderUI({selectInput("selectedBoxplotRegions", "Choose States:",
                                                 region_list5, multiple = TRUE, selected='All') })
  
  # These widgets are for the Histogram tab.
  online4 = reactive({input$rb4})
  
  # These widgets are for the Scatter Plots tab.
  online3 = reactive({input$rb3})
  
  # These widgets are for the Crosstabs tab.
  online1 = reactive({input$rb1})
  KPI_Low = reactive({input$KPI1})     
  KPI_Medium = reactive({input$KPI2})
  
  # These widgets are for the Barcharts tab.
  online2 = reactive({input$rb2})
  output$regions2 <- renderUI({selectInput("selectedRegions", "Choose States:", region_list, multiple = TRUE, selected='All') })
  
  # Begin Box Plot Tab ------------------------------------------------------------------
  dfbp1 <- eventReactive(input$click5, {
    if(input$selectedBoxplotRegions == 'All') region_list5 <- input$selectedBoxplotRegions
    else region_list5 <- append(list("Skip" = "Skip"), input$selectedBoxplotRegions)
    if(online5() == "SQL") {
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = "www/.data.world"),
        dataset="hsfolkes/s-17-dv-final-project/", type="sql",
        query="select Category, State, Cost
        from states_boxplot
        where (? = 'All' or State in (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?))",
        queryParameters = region_list5 ) # %>% View()
    }
    else {
    }
    })
  
  output$boxplotData1 <- renderDataTable({DT::datatable(dfbp1(), rownames = FALSE,
                                                extensions = list(Responsive = TRUE, 
                                                FixedHeader = TRUE)
  )
  })
  
  dfbp2 <- eventReactive(c(input$click5, input$boxCostRange1), {
    dfbp1() %>% dplyr::filter(Cost >= input$boxCostRange1[1] & Cost <= input$boxCostRange1[2]) # %>% View()
  })
  
    
  output$boxplotPlot1 <- renderPlotly({
    #View(dfbp3())
    p <- ggplot(dfbp2(), aes(x = Category, y = Cost)) + 
      geom_boxplot() +
      ylim(input$boxCostRange1[1], input$boxCostRange1[2]) +
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) +
      scale_y_continuous(labels = scales::comma) +
      theme_classic()
    ggplotly(p)
  })
  # End Box Plot Tab ___________________________________________________________
  
  # Begin Histogram Tab ------------------------------------------------------------------
  dfh1 <- eventReactive(input$click4, {
    if(online4() == "SQL") {
      print("Getting from data.world")
      query(
        data.world(propsfile = "www/.data.world"),
        dataset="hsfolkes/s-17-dv-final-project", type="sql",
        query="select State, Librarians
        from states"
      ) # %>% View()
    }
    else {
    }
    })
  
  output$histogramData1 <- renderDataTable({DT::datatable(dfh1(), rownames = FALSE,
                                                  extensions = list(Responsive = TRUE, 
                                                  FixedHeader = TRUE)
  )
  })
  
  output$histogramPlot1 <- renderPlotly({p <- ggplot(dfh1()) +
      geom_histogram(aes(x=Librarians)) +
      geom_dotplot(aes(x = Librarians, color = State)) +
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) +
      labs(x = "Number of Librarians", y = "Number of States with Specified Number of Librarians") +
      theme_classic()
      ggplotly(p)
  })
  # End Histogram Tab ___________________________________________________________
  
  # Begin Scatter Plots Tab ------------------------------------------------------------------
  dfsc1 <- eventReactive(input$click3, {
    if(online3() == "SQL") {
      print("Getting from data.world")
      query(
        data.world(propsfile = "www/.data.world"),
        dataset="hsfolkes/s-17-dv-final-project", type="sql",
        query="select s.State, (Library_Visits / State_Population) as visits_per_pop, B19119_001 as median_fam_income,
        m.State
        from states s
        join `Median Family Income` m on m.State = s.State"
      ) # %>% View()
    }
    else {
    }
  })
  output$scatterData1 <- renderDataTable({DT::datatable(dfsc1(), rownames = FALSE,
                                                 extensions = list(Responsive = TRUE, 
                                                 FixedHeader = TRUE)
  )
  })
  output$scatterPlot1 <- renderPlotly({p <- ggplot(dfsc1()) + 
      theme(axis.text.x=element_text(angle=90, size=16, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=16, hjust=0.5)) +
      geom_point(aes(x=visits_per_pop, y=median_fam_income, colour=State), size=2) +
      geom_smooth(aes(x=visits_per_pop, y=median_fam_income), method = lm) +
      labs(x = "Library Visits per Capita", y = "Median Family Income") +
      theme_classic()
      ggplotly(p)
  })
  # End Scatter Plots Tab ___________________________________________________________
  
# Begin Crosstab Tab ------------------------------------------------------------------
  dfct1 <- eventReactive(input$click1, {
      if(online1() == "SQL") {
        print("Getting from data.world")
        query(
            data.world(propsfile = "www/.data.world"),
            dataset="hsfolkes/s-17-dv-final-project/", type="sql",
            query="select s.State, b.State, Category, Total_Operating_Revenue, b.Cost,
            sum(Library_Visits) as sum_library,
            sum(Service_Population_Without_Duplicates) as sum_pop,
            case
            when sum(Library_Visits) / sum(Service_Population_Without_Duplicates) < ? then 'Low'
            when  sum(Library_Visits) / sum(Service_Population_Without_Duplicates) < ? then 'Medium'
            else 'High'
            end as kpi
            
            from states s join states_boxplot b on s.State = b.State
            group by s.State, Category",
            queryParameters = list(KPI_Low(), KPI_Medium())
          ) # %>% View()
      }
      else {
      }
  })
  output$data1 <- renderDataTable({DT::datatable(dfct1(), rownames = FALSE,
                                extensions = list(Responsive = TRUE, FixedHeader = TRUE)
  )
  })
  output$plot1 <- renderPlot({ggplot(dfct1()) + 
    theme(axis.text.x=element_text(angle=90, size=16, vjust=0.5)) + 
    theme(axis.text.y=element_text(size=16, hjust=0.5)) +
    geom_text(aes(x=Category, y=State, label=Cost), size=6) +
    geom_tile(aes(x=Category, y=State, fill=kpi), alpha=0.50) +
    theme_classic()
  })
# End Crosstab Tab ___________________________________________________________
# Begin Barchart Tab ------------------------------------------------------------------
  dfbc1 <- eventReactive(input$click2, {
    if(input$selectedRegions == 'All') region_list <- input$selectedRegions
    else region_list <- append(list("Skip" = "Skip"), input$selectedRegions)
    if(online2() == "SQL") {
      print("Getting from data.world")
      tdf = query(
        data.world(propsfile = "www/.data.world"),
        dataset="hsfolkes/s-17-dv-final-project/", type="sql",
        query="select State, Librarians, State_Population, State_Code
        from states
        where ? = 'All' or State in (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        group by State",
        queryParameters = region_list
      ) # %>% View()
    }
    else {
    }
    # The following two lines mimic what can be done with Analytic SQL. Analytic SQL does not currently work in data.world.
    tdf2 = tdf %>% group_by(State) %>% summarize(citizens_per_lib = mean(State_Population / Librarians))
    dplyr::inner_join(tdf, tdf2, by = "State")
    
    
  })
  
  df2 <-  query(
    data.world(propsfile = "www/.data.world"),
    dataset="hsfolkes/s-17-dv-final-project/", type="sql",
    query="select State, Hours_Open, State_Code
  from states"
  )  #%>% View()
  
  df3 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="hsfolkes/s-17-dv-final-project/", type="sql",
    query="select * from census_enrollment"
  ) 
  
  join <- inner_join(df2, df3)
  output$barchartData1 <- renderDataTable({DT::datatable(dfbc1(),
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  
  output$barchartData2 <- renderDataTable({DT::datatable(join,
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$barchartPlot1 <- renderPlot({ggplot(dfbc1(), aes(x=State, y=Librarians, fill = citizens_per_lib)) +
      geom_col(stat = "identity") +
      geom_line(aes(x = State_Code, y = mean(Librarians)), colour = "black", size = 1.5) +
  theme_classic()
  })
  
  
  output$barchartPlot2 <- renderPlot({ggplot(data = join) +
      geom_col(aes(x = State, y = Hours_Open, fill = (Hours_Open > 1000000))) +
      scale_y_continuous(labels = scales::comma) +
      labs(x = "State", y = "Library Hours Open") +
      geom_line(aes(x = State_Code, y = Enrollment_9to12), colour = "black", size = 0.5) +
      theme_classic()
  })
  
  
  # End Barchart Tab ___________________________________________________________
  
})
