library(tidyverse)

data <- read.csv('C:/Users/Harol/Downloads/ALL_DATA_2.csv')

# removing outliers
summary(data)


data$bike[data$bike < 0] <- 0
data$bike[data$bike >1000] <- 0

data$lorry[data$lorry < 0] <- 0
data$lorry[data$lorry >1000] <- 0

data$pedestrian[data$pedestrian < 0] <- 0
data$pedestrian[data$pedestrian >1000] <- 0

data$car[data$car < 0] <- 0
data$car[data$car >1000] <- 0

data$bucket0[data$bucket0 < 0] <- 0
data$bucket0[data$bucket0 >1000] <- 0

data$bucket1[data$bucket1 < 0] <- 0
data$bucket1[data$bucket1 >1000] <- 0

data$bucket2[data$bucket2 < 0] <- 0
data$bucket2[data$bucket2 >1000] <- 0

data$bucket3[data$bucket3 < 0] <- 0
data$bucket3[data$bucket3 >1000] <- 0

data$bucket4[data$bucket4 < 0] <- 0
data$bucket4[data$bucket4 >1000] <- 0

data$bucket5[data$bucket5 < 0] <- 0
data$bucket5[data$bucket5 >1000] <- 0

data$bucket6[data$bucket6 < 0] <- 0
data$bucket6[data$bucket6 >1000] <- 0

data$bucket7[data$bucket7 < 0] <- 0
data$bucket7[data$bucket7 >1000] <- 0

data$pct_up[data$pct_up < 0] <- 0
data$pct_up[data$pct_up > 1] <- 0
summary(data)

outlier_remover <- function(input_data){
  start_value <- grep("bike", colnames(input_data))
  for(i in start_value:ncol(input_data)){
  f <- fivenum(data[,i])
  f
  IQR <- f[4]-f[2]
  data[,i][data[,i] >f[4] + 5*IQR | data[,i] <f[2] - 5*IQR]
  }
}
outlier_remover(data)

summary(data)

