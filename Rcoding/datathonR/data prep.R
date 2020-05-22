library(dplyr)

df <- read.csv("C:/Users/J/Downloads/ALL_DATA.csv", encoding="UTF-8")
df$weekday <- weekdays(as.Date(df$date))
df <- as_tibble(df)
test <- df %>% group_by(segment_id,year,month,weekday,hour)
testt2 <- test[1:1000,] %>% summarise(max_speed = first(max_speed),
                   coordinates = first(coordinates),
                   pct_up = first(pct_up),
                   lorry = mean(lorry),
                   pedestrian = mean(pedestrian),
                   bike = mean(bike),
                   car = mean(car),
                   bucket0 = mean(bucket0),
                   bucket1 = mean(bucket1),
                   bucket2 = mean(bucket2),
                   bucket3 = mean(bucket3),
                   bucket4 = mean(bucket4),
                   bucket5 = mean(bucket5),
                   bucket6 = mean(bucket6),
                   bucket7 = mean(bucket7),
                   )
