
# packages ------------------------------------------------------------------------------------

library(tidyverse)
library(tidytext)
library(shiny)
library(shinyBS)
library(shinydashboard)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(Cairo)
library(RColorBrewer)
#library(plotly)
library(feather)
library(DT)
library(leaflet)

# shiny dashboard -----------------------------------------------------------------------------

options(shiny.usecairo = TRUE)

# input data ----------------------------------------------------------------------------------

# Put dataframes here

data_df <- as_tibble(read.csv("finaldata3_final.csv")) %>%
  mutate_at(vars(segment_id),factor)



months_list <- list("January" = 1, "February" = 2,"March" = 3,"April"=4,"May"=5,"June"=6,
                    "July"=7,"August"=8,"September"=9,"October"=10,"November"=11,"December"=12)



province_list <- list("Antwerp" = "Antwerpen", "Limburg" = "Limburg",
                      "Flemish Brabant" = "Vlaams-Brabant",  "East Flanders" =  "Oost-Vlaanderen",
                      "West Flanders" = "West-Vlaanderen",  "Hainaut" = "",  "Walloon Brabant" = "",
                      "Namur" = "",  "Liege" = "",  "Luxembourg" = "", "Brussels" = "Brussel")


# ui ------------------------------------------------------------------------------------------

ui <- fluidPage(
  
  #### header ####
      header <- headerPanel(list(
        tags$div(style="float:left;padding-right:30px", tags$img(src="finalpolicelarger.png", height=100)))),
        #tags$h1( 'Traffic Camera Deployment Advisor',style = "color: #10069F; font-weight: bold; font-size: 80px;"))
                 
  #### body ####
  
  dashboardBody(
    #### css layout for dashboard ####
    
    #Setting up the colors
    #orange: #DE8D5E
    #dark blue: #10069F
    #light blue: #94B7BB
    tags$head(tags$style(HTML("
                              .content {background-color: #ffffff;}
                              .tabbable > .nav > li > a                  {background-color: #94B7BB;  color:white}
                              .tabbable > .nav > li[class=active]    > a {background-color: #10069F; color:white}
                              .tabbable > .nav > li > a   {font-size: 20px}
                              * {font-family: 'TheSans B5 Plain';}
                              .js-irs-0 .irs-from,.js-irs-0 .irs-to, .js-irs-0 .irs-bar-edge {background: #DE8D5E}
                              .js-irs-0 .irs-bar {background: #DE8D5E; border-top:1px solid #DE8D5E; border-bottom:1px solid #DE8D5E}
                              .js-irs-1 .irs-single {background: #DE8D5E}
                              .js-irs-1 .irs-bar-edge {background: #DE8D5E; border: 1px solid #DE8D5E}
                              .js-irs-1 .irs-bar {background: #DE8D5E; border-top:1px solid #DE8D5E; border-bottom:1px solid #DE8D5E}
                              table.dataTable tr.selected td, table.dataTable td.selected {background-color: pink;}
                              ")
                              )
                            ),
    
      fluidRow(
      #The wellpanel for the settings
      column(3,
             h3("Settings",style = "color: #10069F;font-weight: bold;"),
             wellPanel(
               fluidRow(column(12,
                               helpText(HTML("Select the month, day and hours for monitoring by police units.<br>
                               Note: March-September there are no data available yet"))
               )
               ),
               fluidRow(
                 column(6,
                        selectInput("month",h4("Month",style = "color: #10069F;font-weight: bold;"), choices = months_list, selected = 1)
                 ),
                 column(6,
                        uiOutput("day_input")
                  )
               ),
               fluidRow(column(12,
                 sliderInput("hour_slider", h4("Hour range",style="color: #10069F;font-weight: bold;"),
                             min = 8, max = 17, value = c(10, 13),step=1)
               )
               ),
               fluidRow(column(12,
                 helpText(HTML("Select the ratio between maximizing income and minimizing traffic risk.<br>
                               Note: 0% means maximal profit, 100% means maximal risk reduction ")),
                 sliderInput("ratio_slider",h4("Max income / Min risk trade-off",style="color: #10069F;font-weight: bold;"),
                           post="%",
                           0, 100, 50)
               )
               ),
               fluidRow(
                 column(5,
                               selectInput("province",h4("Province",style="color: #10069F;font-weight: bold;"),
                                           choices = province_list, selected = 3)
               ),
                 column(7,
                      helpText(HTML("<br>
                                Select the province for the analysis.<br>
                                Note: Only streets from the selected province will be considered"))
                      
               )
               ),
               fluidRow(
                 column(3, 
                        numericInput("units", 
                                     h4("Units",style="color: #10069F;font-weight: bold;"), 
                                     value = 10)
                        ),
                 column(9,
                        helpText(HTML("<br><br>
                                Select the number of police units available.<br>
                                Note: 1 unit can monitor one street"))
                        
                 )
               )
             )
        ),
    column(9,
           #Tabs ####
           tabsetPanel(

             tabPanel("Streets",
                      wellPanel(
                        DT::dataTableOutput("table")
                      )
             ),
             
             #tabPanel("Expected utility breakdown",
             #         wellPanel(
             #           plotlyOutput("bar_plot",height = 680)
              #        )
             #),
             
             tabPanel("Map",
                      tags$style(type = "text/css", "#map_plot {height: calc(100vh - 250px);}"),
                      #The box with the map
                      wellPanel(
                        leafletOutput("map_plot",height = 680)
                      )
             ),
             tabPanel("About",
                      includeMarkdown("AboutUs.Rmd"))
             )
      )
      )
  )
  )

# server --------------------------------------------------------------------------------------
# Put action events here

server <- function(input, output) {
  
  #max value does not work for some reason :(

  output$day_input <- renderUI({
    days_in_month <- c(31,29,31,30,31,30,
                       31,31,30,31,30,31)
    numericInput("day", 
                 h4("Day",style="color: #10069F;font-weight: bold;"), 
                 min=1,
                 max=days_in_month[as.numeric(input$month)],
                 step=1,
                 value = 10)
  })
  
  #Only calculate the filtered streets once
  vals <- reactiveValues()
  observeEvent(c(input$day,input$month,input$hour_slider,input$ratio_slider,input$units,input$province),{
    validate(need(input$day > 0, ''))
    ratio <- input$ratio_slider/100
    vals$table_df <- data_df %>%
      filter(province==input$province) %>% 
      filter(month == as.numeric(input$month)) %>% 
      filter(weekday == weekdays(as.Date(paste("2020",input$month,input$day,sep="-")))) %>% 
      filter(hour >= input$hour_slider[1]) %>% 
      filter(hour <= input$hour_slider[2]) %>%
      mutate(utility=((1-ratio)*expectedfinescaled+ratio*riskscore)) %>% 
      group_by(segment_id) %>% 
      summarise(Utility=mean(utility),Income=mean(expectedfine),Risk=mean(riskscore),Cars=mean(car),
                X=first(X),Y=first(Y),Street=first(street)) %>% 
      arrange(desc(Utility)) %>% 
      slice(1:input$units)
  })

  #Placeholder for map plot
  output$map_plot <- renderLeaflet({
    
    colfunc <- colorRampPalette(c("yellow", "orange", "red"))
    all_colors <- colfunc(100)
    
    pal_u <- colorNumeric(all_colors, domain = vals$table_df$Utility)
    pal_i <- colorNumeric(all_colors, domain = vals$table_df$Income)
    pal_r <- colorNumeric(all_colors, domain = vals$table_df$Risk)
    pal_c <- colorNumeric(all_colors, domain = vals$table_df$Cars)
    
    m <- leaflet(data=vals$table_df,height = "100%") %>%
      addProviderTiles(providers$CartoDB.Positron) %>%  # Add default OpenStreetMap map tiles
      #50.87312, 4.70459
      addCircleMarkers(lng=~X, lat=~Y,color=~pal_u(Utility),radius=10,popup =~Street,group="Utility") %>%
      addCircleMarkers(lng=~X, lat=~Y,color=~pal_i(Income),radius=10,popup =~Street,group="Income") %>%
      addCircleMarkers(lng=~X, lat=~Y,color=~pal_r(Risk),radius=10,popup =~Street,group="Risk") %>%
      addCircleMarkers(lng=~X, lat=~Y,color=~pal_c(Cars),radius=10,popup =~Street,group="Cars") %>%
      addLayersControl(
        baseGroups = c("Utility", "Income", "Risk","Cars"),
        options = layersControlOptions(collapsed = FALSE)
      )

    m  # Print the map
  })

  
  #Placeholder for utility bar plot
  # output$bar_plot <- renderPlotly({
  #   p <- plot_ly(vals$table_df, x = ~segment_id, y = ~Income, type = 'bar', name = 'Projected income') %>%
  #     add_trace(y = ~Risk, name = 'Projected risk reduction') %>%
  #     layout(yaxis = list(title = 'Count'), barmode = 'group')
  #   p
  # })
  
  #The table with the streets
  output$table = DT::renderDataTable({
    
    DT::datatable(vals$table_df %>% 
                    select(segment_id,Street,Utility,Income,Risk,Cars),
                  rownames = F,colnames = c('ID','Street name','Utility score', 'Projected income', 'Risk reduction','Number of cars'),
                  class = 'display cell-border compact hover',
                  options = list(lengthMenu = c(10, 25, 50), pageLength = 10))%>%
                  formatStyle("Utility",
                  background = styleColorBar(range(vals$table_df$Utility), '#94B7BB'),
                  backgroundSize = '98% 88%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')%>%
                  formatStyle("Income",
                  background = styleColorBar(range(vals$table_df$Income), '#94B7BB'),
                  backgroundSize = '98% 88%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')%>%
                  formatStyle("Risk",
                  background = styleColorBar(range(vals$table_df$Risk), '#94B7BB'),
                  backgroundSize = '98% 88%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')%>%
                  formatStyle("Cars",
                  background = styleColorBar(range(vals$table_df$Cars), '#94B7BB'),
                  backgroundSize = '98% 88%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })
  
}

# app -----------------------------------------------------------------------------------------

shinyApp(ui, server)