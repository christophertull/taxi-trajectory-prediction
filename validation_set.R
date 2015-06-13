#!/usr/bin/RScript

##TODO: clean and comment


require(rjson)
require(data.table)
require(ggplot2)

train <- read.csv("data/train.csv")
train <- data.table(train)

##
#train <- train[MISSING_DATA!='True']

##
train <- train[POLYLINE!='[]']
setkey(train, TRIP_ID)

##
train[, TIMESTAMP:=(as.POSIXct(as.integer(TIMESTAMP), origin="1970-01-01", tz='GMT'))]
train[, sample_date:=as.Date(TIMESTAMP)]

## the same days as in test set but for 2013
dates <- as.Date(c("2013-08-14", "2013-09-30", "2013-10-06", "2013-11-01" , "2013-12-21"))
valid <- train[sample_date %in% dates]


#######################
## forked
test <- read.csv("data/test.csv")
test <- data.table(test)


##
test <- test[POLYLINE!='[]']
setkey(test, TRIP_ID)

##
test[, POLYLINE:=as.character(POLYLINE)]

##
test[, TIMESTAMP:=(as.POSIXct(as.integer(TIMESTAMP), origin="1970-01-01", tz='GMT'))]
test[, sample_date:=as.Date(TIMESTAMP)]
##
unique(test$sample_date)
#[1] "2014-08-14" "2014-09-30" "2014-10-06" "2014-11-01" "2014-12-21"

##
test[, SNAPSHOTS:=length(fromJSON(as.character(POLYLINE))), by=TRIP_ID]
test[, duration_snapshots:=SNAPSHOTS*15/60]
##
ggplot(test) + geom_histogram(aes(x=duration_snapshots), binwidth=5) + theme_bw()



##
test[, CUTOFF:=max(TIMESTAMP), by=sample_date]
test[, duration_timestamp:=as.numeric(CUTOFF-TIMESTAMP)/60]

##############

times <- unique(test$CUTOFF) - 365*24*60*60


valid[, end_time:=TIMESTAMP + length(fromJSON(as.character(POLYLINE)))*15, by=TRIP_ID]
valid[, cutoff:=max(TIMESTAMP), by=sample_date]
valid1 <- valid[end_time>=cutoff & TIMESTAMP<cutoff]

valid1 <- as.data.frame(valid1)

valid1$cut_polyline <- "a"
valid1$trun_length <- 0
valid1$trun_time <- 0
valid1$LATITUDE <- 0
valid1$LONGITUDE <- 0


for (i in seq_len(nrow(valid1))){
  row <- valid1[i,]
  pol <- unique(fromJSON(as.character(row$POLYLINE)))
  pos <- tail(pol,1)
  for (j in c(1:length(pol))) {
	duration <- row$TIMESTAMP+15*length(pol[1:j])
        if (duration>=row$cutoff) break}
  valid1[i,'cut_polyline'] <- toJSON(unique(pol[1:j-1]))
  valid1[i,'trun_length'] <- length(unique(pol[1:j-1])) 
  valid1[i,'trun_time'] <- length(unique(pol[1:j-1]))*15/60
  valid1[i,'LATITUDE'] <- pos[[1]][2]
  valid1[i,'LONGITUDE'] <- pos[[1]][1]
}


ggplot(valid1) + geom_histogram(aes(x=trun_time), binwidth=5) + theme_bw()

valid2 <- valid1[which(valid1$trun_time<200),]

ggplot(valid2) + geom_histogram(aes(x=trun_time), binwidth=3) + theme_bw()

valid2 <- valid2[,c("TRIP_ID","CALL_TYPE","ORIGIN_CALL","ORIGIN_STAND","TAXI_ID","TIMESTAMP","DAY_TYPE","MISSING_DATA","cut_polyline","LATITUDE","LONGITUDE")]

fields <- c("TRIP_ID", "CALL_TYPE", "ORIGIN_CALL", "ORIGIN_STAND", "TAXI_ID", "TIMESTAMP", "DAY_TYPE", "MISSING_DATA", "POLYLINE", "LATITUDE", "LONGITUDE")  
names(valid2) <- fields

write.csv(valid2,'validation.csv', row.names=FALSE)

