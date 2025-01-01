# Air Quality Visualization and Prediction Platform

## Description

The "Air Quality Visualization and Prediction Platform" is a Shiny web application designed to provide users with insights into air quality data across various countries. The app allows users to visualize air quality trends, rankings, and geographic distribution, and also includes a predictive feature that uses the SARIMAX model to forecast future air quality levels based on historical data and external influencing variables.

## Repository Contents

- `app.R`: The main Shiny app script containing both UI and server logic.
- `data/`: A directory containing the air quality dataset (`final_datasetfile.csv`) used in the application.
- `scripts/`: Additional R scripts for preprocessing and model building.
- `README.md`: Detailed documentation for the repository.
- `LICENSE`: Licensing information for the project.

## Installation Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/air-quality-app.git
   cd air-quality-app
   ```
2. Install required R packages:
   ```R
   if (!require(shiny)) install.packages("shiny")
   if (!require(ggplot2)) install.packages("ggplot2")
   if (!require(dplyr)) install.packages("dplyr")
   if (!require(readr)) install.packages("readr")
   if (!require(leaflet)) install.packages("leaflet")
   if (!require(tidyr)) install.packages("tidyr")
   if (!require(forecast)) install.packages("forecast")
   if (!require(scales)) install.packages("scales")
   ```

## Usage Instructions

- **Locally:**

  1. Open RStudio and set the working directory to the cloned repository.
  2. Run the Shiny app:
     ```R
     library(shiny)
     runApp("app.R")
     ```
  3. Access the app in your web browser at [http://127.0.0.1:6690/](http://127.0.0.1:6690/)  . &#x20;

- **ShinyApps.io:**

  1. Visit the deployment link provided below.
  2. Interact with the app directly in your web browser.

## Data Information

- **Source:** The air quality dataset is hosted on GitHub and contains metrics such as PM2.5, PM10, NO2, O3, SO2, and DAQI (Daily Air Quality Index).
- **Format:** CSV format with columns for country, date, and air quality indicators.
- **Preprocessing Steps:**
  - Conversion of timestamps to `Date` format.
  - Splitting of geographic coordinates into latitude and longitude.
  - Standardization of external variables (e.g., PM2.5, PM10) during the prediction phase.

## Key Features

1. **Air Quality Map:** Displays the geographic distribution of air quality metrics for different countries.
2. **Air Quality Trend:** Visualizes monthly trends for selected countries.
3. **Country Ranking:** Provides a ranking of countries based on average air quality levels.
4. **Prediction Module:** Forecasts future DAQI levels using the SARIMAX model, incorporating historical data and external influencing variables.

## Deployment Links

- [Shiny App on ShinyApps.io](https://wqd7001-shiny-asia-air-quality-app.shinyapps.io/shiny-air-quality-app/)   &#x20;

## Contact Information

- **Email:**
  - [23052209@siswa365.um.edu.my](mailto:23052209@siswa365.um.edu.my)
  - [23113750@siswa365.um.edu.my](mailto:23113750@siswa365.um.edu.my)
  - [22102113@siswa365.um.edu.my](mailto:22102113@siswa365.um.edu.my)
  - [24059242@siswa365.um.edu.my](mailto:24059242@siswa365.um.edu.my)
  - [23111363@siswa365.um.edu.my](mailto:23111363@siswa365.um.edu.my)
- **GitHub Issues:** [https://github.com/sayuleri/shiny-air-quality-app/issues](https://github.com/sayuleri/shiny-air-quality-app/issues)   &#x20;

## Licensing

This project is licensed under the MIT License. See the `LICENSE` file for details.

