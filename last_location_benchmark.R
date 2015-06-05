library(readr)
library(rjson)

test  <- read_csv("data/test.csv")

positions <- function(row) as.data.frame(do.call(rbind, fromJSON(row$POLYLINE)))
last_position <- function(row) tail(positions(row), 1)

submission <- test["TRIP_ID"]

for (i in 1:nrow(test)) {
  pos <- last_position(test[i,])
  submission[i, "LATITUDE"] <- pos[2]
  submission[i, "LONGITUDE"] <- pos[1]
}

write_csv(submission, "data/last_location_benchmark.csv")
