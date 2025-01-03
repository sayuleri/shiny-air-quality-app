# Install necessary packages
if (!require(shiny)) install.packages("shiny")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")
if (!require(readr)) install.packages("readr")
if (!require(leaflet)) install.packages("leaflet")
if (!require(tidyr)) install.packages("tidyr")
if (!require(forecast)) install.packages("forecast")
if (!require(scales)) install.packages("scales")

# Load packages
library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(leaflet)
library(tidyr)
library(forecast)
library(scales)

# Read the data
# data <- read.csv("D:/BaiduSyncdisk/UM/WQD7001/group/final_datasetfile.csv")

# current_dir <- getwd()
# file_path <- file.path(current_dir, "final_datasetfile.csv")
# data <- read.csv(file_path)
# print(paste("File loaded from:", file_path))
# str(data)

# Read the data from GitHub
github_url <- "https://raw.githubusercontent.com/sayuleri/shiny-air-quality-app/main/final_datasetfile.csv"

data <- read.csv(github_url)
# print("File successfully loaded from GitHub.")
# str(data)


# Rename columns for compatibility
data <- data %>%
  rename(
    Date = timestamp,
    YearMonth = year_month,
    City = country,
    Coordinate = coordinate
  )

# Convert timestamp to Date format
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")

# Split Coordinate into Latitude and Longitude
data <- data %>%
  separate(Coordinate, into = c("Latitude", "Longitude"), sep = ",", convert = TRUE)

# Ensure proper formatting of necessary columns
data <- data %>%
  mutate(
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude)
  )

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      #homepage {
        height: 100vh;
        width: 100vw;
        position: absolute;
        top: 0;
        left: 0;
        z-index: -1;
      }
      .title-overlay {
        position: absolute;
        top: 20px;
        left: 50%;
        transform: translate(-50%, 0);
        font-size: 36px;
        font-weight: bold;
        color: white;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.7);
        z-index: 1000;
      }
      .controls-panel {
        position: absolute;
        top: 300px;
        left: 200px;
        z-index: 1000;
        background-color: rgba(255, 255, 255, 0.9);
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.3);
      }
      .visualization-panel {
        margin-top: 150px;
        padding: 20px;
        z-index: 1;
      }
    "))
  ),
  div(id = "homepage", leafletOutput("background_map", width = "100%", height = "100%")),
  div(class = "title-overlay", "Air Quality Visualization and Prediction Platform"),
  div(
    id = "main-panel",
    sidebarLayout(
      sidebarPanel(
        class = "controls-panel",
        selectInput(
          "visualization",
          "Select Visualization:",
          choices = list(
            "Air Quality Map" = "map",
            "Air Quality Trend" = "trend",
            "Country Ranking" = "country_rank",
            "DAQI Prediction" = "prediction"
          )
        ),
        conditionalPanel(
          condition = "input.visualization == 'map'",
          selectInput(
            "map_metric",
            "Select Metric:",
            choices = list(
              "PM2.5" = "AQI_PM2.5",
              "PM10" = "AQI_PM10",
              "NO2" = "AQI_NO2",
              "O3" = "AQI_O3",
              "SO2" = "AQI_SO2",
              "DAQI" = "DAQI"
            )
          )
        ),
        conditionalPanel(
          condition = "input.visualization == 'trend'",
          selectInput(
            "country_select",
            "Select Country:",
            choices = unique(data$City),
            selected = unique(data$City)[1]
          )
        ),
        conditionalPanel(
          condition = "input.visualization == 'prediction'",
          selectInput(
            "prediction_country",
            "Select Country:",
            choices = unique(data$City),
            selected = unique(data$City)[1]
          )
        ),
        actionButton("go", "Go")
      ),
      mainPanel(
        div(class = "visualization-panel", uiOutput("page_output"))
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Render homepage background map
  output$background_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
      setView(lng = 100, lat = 30, zoom = 3)
  })
  
  observeEvent(input$go, {
    if (input$visualization == "map") {
      output$page_output <- renderUI({
        leafletOutput("map_plot", height = "70vh")
      })
      output$map_plot <- renderLeaflet({
        validate(
          need("Latitude" %in% colnames(data), "Latitude column is missing."),
          need("Longitude" %in% colnames(data), "Longitude column is missing."),
          need(input$map_metric %in% colnames(data), paste("Selected metric", input$map_metric, "is missing from the dataset."))
        )
        
        palette <- colorBin(
          palette = c("#AAD2A3", "#FCEA89", "#F6A6A6", "#D8B4FC"),
          domain = data[[input$map_metric]],
          bins = c(0, 3, 6, 9, 10)
        )
        
        leaflet(data) %>%
          addProviderTiles(providers$CartoDB.Positron) %>% # map-EN
          addCircleMarkers(
            lng = ~Longitude,
            lat = ~Latitude,
            color = ~palette(data[[input$map_metric]]),
            popup = ~paste("City:", City, "<br>", input$map_metric, ":", data[[input$map_metric]]),
            radius = ~sqrt(data[[input$map_metric]]) / 2
          ) %>%
          addLegend(
            position = "bottomright",
            pal = palette,
            values = ~data[[input$map_metric]],
            title = input$map_metric,
            opacity = 1
          ) %>%
          setView(
            lng = mean(data$Longitude, na.rm = TRUE),
            lat = mean(data$Latitude, na.rm = TRUE),
            zoom = 4
          )
      })
    } else if (input$visualization == "trend") {
      output$page_output <- renderUI({
        plotOutput("trend_plot", height = "70vh")
      })
      output$trend_plot <- renderPlot({
        validate(
          need("Date" %in% colnames(data), "Date column is missing."),
          need("DAQI" %in% colnames(data), "DAQI column is missing."),
          need(input$country_select %in% unique(data$City), "Selected country is missing from the dataset.")
        )
        
        country_data <- data %>%
          filter(City == input$country_select) %>%
          mutate(YearMonth = format(Date, "%Y-%m")) %>%
          group_by(YearMonth) %>%
          summarise(DAQI = as.numeric(names(sort(table(DAQI), decreasing = TRUE))[1]))
        
        ggplot(country_data, aes(x = YearMonth, y = DAQI, group = 1)) +
          geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 1, ymax = 3), fill = "#AAD2A3", alpha = 0.5) +
          geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 3.01, ymax = 6), fill = "#FCEA89", alpha = 0.5) +
          geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 6.01, ymax = 9), fill = "#F6A6A6", alpha = 0.5) +
          geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 9.01, ymax = 10), fill = "#D8B4FC", alpha = 0.5) +
          geom_line(color = "black", size = 1.2) +
          geom_point(color = "orange", size = 3) +
          scale_y_continuous(breaks = seq(1, 10, by = 1)) +
          labs(
            title = paste("Monthly DAQI Trend in", input$country_select),
            x = "Month",
            y = "DAQI"
          ) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
      })
    } else if (input$visualization == "country_rank") {
      output$page_output <- renderUI({
        plotOutput("country_rank_plot", height = "70vh")
      })
      output$country_rank_plot <- renderPlot({
        validate(
          need("DAQI" %in% colnames(data), "DAQI column is missing."),
          need("City" %in% colnames(data), "City column is missing.")
        )
        
        country_rank <- data %>%
          group_by(City) %>%
          summarise(Avg_DAQI = round(mean(DAQI, na.rm = TRUE))) %>%
          arrange(desc(Avg_DAQI))
        
        ggplot(country_rank, aes(x = reorder(City, -Avg_DAQI), y = Avg_DAQI, fill = Avg_DAQI)) +
          geom_bar(stat = "identity") +
          scale_fill_gradientn(
            colours = c("#AAD2A3", "#FCEA89", "#F6A6A6", "#D8B4FC"),
            values = scales::rescale(c(1, 3, 6, 9, 10))
          ) +
          labs(
            title = "Country Ranking by Average DAQI",
            x = "Country",
            y = "Average DAQI"
          ) +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
      })
    }else if (input$visualization == "prediction") {
  output$page_output <- renderUI({
    tags$div(
      tags$img(
        src = paste0(
          "https://raw.githubusercontent.com/sayuleri/shiny-air-quality-app/main/visualization_predict/",
          input$prediction_country, "_aqi_prediction.png"
        ),
        alt = paste("Prediction for", input$prediction_country),
        style = "width:100%; height:auto; max-height:70vh;"
      )
    )
  })
}

  })
}

# Run the application
shinyApp(ui = ui, server = server)
