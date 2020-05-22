library(leaflet)
library(sp)
library(ggplot2)
# ---------------- not useful starts code --------------------------------------------------
data <- read.csv('C:/KU Leuven/Datathon2020/Datathon/Rcoding/datathonR/tamtamdata_coordinates_splitted.csv')
data_unique <- unique(data[,c('X','Y')])

df <- data.frame(longitude=data_unique$X, latitude=data_unique$Y)

coordinates(df) <- ~longitude+latitude

data_unique$random_values <- sample(runif(nrow(data_unique),min=0, max=1), size = nrow(data_unique), replace = TRUE)
data_unique$random_values <- round(data_unique$random_values, digits = 2)
data_unique$random_values
# ----------------- not useful code ends here ------------------------------------

colfunc <- colorRampPalette(c("green","yellow", "red"))
all_colors <- colfunc(100)

pal <- colorNumeric(all_colors, domain = data_unique$random_values)

leaflet(df) %>%addCircleMarkers(
  radius = 2,
  color = pal(data_unique$random_values)
)%>%addTiles()

