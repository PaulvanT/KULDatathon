library(dplyr)
library(scales)

### READ IN COMPLETE DATAFRAME FROM DROPBOX
#df <- read.csv("Complete_data_test.csv", encoding="UTF-8")

df <- dplyr::filter(df,!((bucket0==0)&(bucket1==0)&(bucket2==0)&(bucket3==0)&(bucket4==0)&(bucket5==0)&(bucket6==0)&(bucket7==0)))

df$province <- as.character(df$province)
df$province[df$province == ""] <- "Brussel"


df$weekday <- weekdays(as.Date(df$date))
df <- as_tibble(df)
df <- df %>% group_by(segment_id,month,weekday,hour)
df <- df %>% summarise(max_speed = first(max_speed),
                   coordinates = first(coordinates),
                   X = first(X),
                   Y = first(Y),
                   street = first(street),
                   place = first(place),
                   province = first(province),
                   pct_up = mean(pct_up),
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


########### OUTLIER DELETION
df$bike[df$bike < 0] <- 0
df$bike[df$bike >1000] <- 0

df$lorry[df$lorry < 0] <- 0
df$lorry[df$lorry >1000] <- 0

df$pedestrian[df$pedestrian < 0] <- 0
df$pedestrian[df$pedestrian >1000] <- 0

df$car[df$car < 0] <- 0
df$car[df$car >1000] <- 0

df$bucket0[df$bucket0 < 0] <- 0
df$bucket0[df$bucket0 >1000] <- 0

df$bucket1[df$bucket1 < 0] <- 0
df$bucket1[df$bucket1 >1000] <- 0

df$bucket2[df$bucket2 < 0] <- 0
df$bucket2[df$bucket2 >1000] <- 0

df$bucket3[df$bucket3 < 0] <- 0
df$bucket3[df$bucket3 >1000] <- 0

df$bucket4[df$bucket4 < 0] <- 0
df$bucket4[df$bucket4 >1000] <- 0

df$bucket5[df$bucket5 < 0] <- 0
df$bucket5[df$bucket5 >1000] <- 0

df$bucket6[df$bucket6 < 0] <- 0
df$bucket6[df$bucket6 >1000] <- 0

df$bucket7[df$bucket7 < 0] <- 0
df$bucket7[df$bucket7 >1000] <- 0

df$pct_up[df$pct_up < 0] <- 0
df$pct_up[df$pct_up > 1] <- 0
summary(df)

#outlier_remover <- function(input_df){
#  start_value <- grep("bike", colnames(input_df))
#  end_value <- grep("bucket7",colnames(input_df))
#  for(i in start_value:end_value){
#    f <- fivenum(df[,i])
#    f
#    IQR <- f[4]-f[2]
#    df[,i][df[,i] >f[4] + 5*IQR | df[,i] <f[2] - 5*IQR]
#  }
#}
#outlier_remover(df)

############################








# add expected fine
df <- df %>% mutate(expectedfine = bucket7*152 + bucket6*64 + bucket5*0.4*53)

# add road risk score
A1 = 0.01
A2 = 0.03
A3 = 0.09

Bikecoef = 0.1
Carcoef = 0.01
Pedcoef = 0.05
Lorcoef = 0.01

df <- df %>% mutate(speederrisk = A1 * bucket5 + A2 * bucket6 + A3 * bucket7,
                    roadrisk = Bikecoef * bike + Pedcoef * pedestrian + Lorcoef * lorry + Carcoef * car,
                    riskscore = speederrisk+roadrisk)

df$riskscore <- rescale(df$riskscore, to = c(0, 1))

df$expectedfinescaled <- rescale(df$expectedfine, to = c(0,1))


write.csv(df,"finaldata.csv")

