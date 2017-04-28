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

# The following query is for the Barcharts -> High Sales Customers tab data.
if(online0) {
  # Step 1:
  highDiscounts <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="cannata/superstoreorders", type="sql",
    query="
    SELECT distinct Order_Id, sum(Discount) as sumDiscount
    FROM SuperStoreOrders
    group by Order_Id
    having sum(Discount) >= .3"
  ) # %>% View()
  # View(highDiscounts)
  
  # Step 2
  sales <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="cannata/superstoreorders", type="sql",
    query="
    select Customer_Id, sum(Profit) as sumProfit
    FROM SuperStoreOrders
    where Order_Id in 
      (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    group by Customer_Id",
    queryParameters = highDiscounts$Order_Id
    ) # %>% View()
  # View(sales)
} else {
  print("Getting discounts from csv")
  file_path = "www/SuperStoreOrders.csv"
  df <- readr::read_csv(file_path) 
  # Step 1
  highDiscounts <- df %>% dplyr::group_by(Order_Id) %>% dplyr::summarize(sumDiscount = sum(Discount)) %>% dplyr::filter(sumDiscount >= .3)
  # View(highDiscounts)
  # Step 2
  sales <- df %>% dplyr::filter(Order_Id %in% highDiscounts$Order_Id) %>% dplyr::select(Customer_Name, Customer_Id, City, State, Order_Id, Profit) %>% dplyr::group_by(Customer_Name, Customer_Id, City, State, Order_Id) %>% dplyr::summarise(sumProfit = sum(Profit))
  # View(sales)
}

############################### Start shinyServer Function ####################

shinyServer(function(input, output) {
  
  # These widgets are for the Barcharts tab.
  online2 = reactive({input$rb2})
  output$regions2 <- renderUI({selectInput("selectedRegions", "Choose Regions:", region_list, multiple = TRUE, selected='All') })
  
# Begin Barchart Tab ------------------------------------------------------------------
  dfbc1 <- eventReactive(input$click2, {
    if(input$selectedRegions == 'All') region_list <- input$selectedRegions
    else region_list <- append(list("Skip" = "Skip"), input$selectedRegions)
    if(online2() == "SQL") {
      print("Getting from data.world")
      tdf = query(
        data.world(propsfile = "www/.data.world"),
        dataset="cannata/superstoreorders", type="sql",
        query="select Category, Region, sum(Sales) sum_sales
                from SuperStoreOrders
                where ? = 'All' or Region in (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                group by Category, Region",
        queryParameters = region_list
      ) # %>% View()
    }
    else {    }
    # The following two lines mimic what can be done with Analytic SQL. Analytic SQL does not currently work in data.world.
    tdf2 = tdf %>% group_by(Category) %>% summarize(window_avg_sales = mean(sum_sales))
    dplyr::inner_join(tdf, tdf2, by = "Category")

  })
  output$barchartData1 <- renderDataTable({DT::datatable(dfbc1(),
                        rownames = FALSE,
                        extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })

  output$barchartData3 <- renderDataTable({DT::datatable(sales,
                        rownames = FALSE,
                        extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$barchartPlot1 <- renderPlot({ggplot(dfbc1(), aes(x=Region, y=sum_sales)) +
      scale_y_continuous(labels = scales::comma) + # no scientific notation
      theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=12, hjust=0.5)) +
      geom_bar(stat = "identity") + 
      facet_wrap(~Category, ncol=1) + 
      coord_flip() + 
      # Add sum_sales, and (sum_sales - window_avg_sales) label.
      geom_text(mapping=aes(x=Region, y=sum_sales, label=round(sum_sales)),colour="black", hjust=-.5) +
      geom_text(mapping=aes(x=Region, y=sum_sales, label=round(sum_sales - window_avg_sales)),colour="blue", hjust=-2) +
      # Add reference line with a label.
      geom_hline(aes(yintercept = round(window_avg_sales)), color="red") +
      geom_text(aes( -1, window_avg_sales, label = window_avg_sales, vjust = -.5, hjust = -.25), color="red")
  })
    output$barchartPlot2 <- renderPlotly({
    # The following ggplotly code doesn't work when sumProfit is negative.
    p <- ggplot(sales, aes(x=as.character(Customer_Id), y=sumProfit)) +
      theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=12, hjust=0.5)) +
      geom_bar(stat = "identity")
    ggplotly(p)
    # So, using plot_ly instead.
    plot_ly(
      data = sales,
      x = ~as.character(Customer_Id),
      y = ~sumProfit,
      type = "bar"
      ) %>%
      layout(
        xaxis = list(type="category", categoryorder="category ascending")
      )
  })
  # End Barchart Tab ___________________________________________________________
  
})
