#!/usr/bin/RScript
## this script creates validation set for internal prediction algorithms testing
## this script partly implements logic proposed in: 

packs <- suppressWarnings(require(rjson) & require(data.table) & require(ggplot2))
if (!packs) print('please install all aforementioned packages')


## TODO: make a reading function
## read raw train and test data to data.table
train <- read.csv("data/train.csv")
train <- data.table(train)

test <- read.csv("data/test.csv")
test <- data.table(test)

## we are not interesred in missing data as for now
train <- train[POLYLINE!='[]']
setkey(train, TRIP_ID)

test <- test[POLYLINE!='[]']
setkey(test, TRIP_ID)


## convert unix timestamps to human readable date and time
train[, TIMESTAMP:=(as.POSIXct(as.integer(TIMESTAMP), origin="1970-01-01", tz='GMT'))]
test[, TIMESTAMP:=(as.POSIXct(as.integer(TIMESTAMP), origin="1970-01-01", tz='GMT'))]

## extract corresponding date 
train[, date:=as.Date(TIMESTAMP)]
test[, date:=as.Date(TIMESTAMP)]

## extract all unique dates for the test set (there are 5 days in 2014) 
dates <- as.Date(unique(test$date))

## extract the same dates from the train set (in 2013)
valid <- train[date %in% dates-365]

## plotting a histogram of duration of trips tracking time in the test test 
test[, POLYLINE:=as.character(POLYLINE)]
test[, snapshot:=length(fromJSON(POLYLINE)), by=TRIP_ID]
test[, snapshot_duration:=snapshot*15/60]
ggplot(test) + geom_histogram(aes(x=snapshot_duration), binwidth=5) + theme_bw()
ggsave('snapshots_duration.png')

## use a maximum timestamp within each day as a cutoff time for a validation set 
test[, cutoff:=max(TIMESTAMP), by=date]
times <- unique(test$cutoff) - 365*24*60*60


## TODO: correct a mistake with maximum time 
## TODO: fixed merging conflict

valid[, end_time:=TIMESTAMP + length(fromJSON(POLYLINE))*15, by=TRIP_ID]
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

<<<<<<< HEAD
valid2 <- valid1[which(valid1$trun_time<200),]
=======
##
test[, SNAPSHOTS:=length(fromJSON(as.character(POLYLINE))), by=TRIP_ID]
test[, duration_snapshots:=SNAPSHOTS*15/60]
##
ggplot(test) + geom_histogram(aes(x=duration_snapshots), binwidth=5) + theme_bw()
>>>>>>> a826da198147af1dc9a93272a719f3108b2a64de

ggplot(valid2) + geom_histogram(aes(x=trun_time), binwidth=3) + theme_bw()

valid2 <- valid2[,c("TRIP_ID","CALL_TYPE","ORIGIN_CALL","ORIGIN_STAND","TAXI_ID","TIMESTAMP","DAY_TYPE","MISSING_DATA","cut_polyline","LATITUDE","LONGITUDE")]

fields <- c("TRIP_ID", "CALL_TYPE", "ORIGIN_CALL", "ORIGIN_STAND", "TAXI_ID", "TIMESTAMP", "DAY_TYPE", "MISSING_DATA", "POLYLINE", "LATITUDE", "LONGITUDE")  
names(valid2) <- fields

<<<<<<< HEAD
=======
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

>>>>>>> a826da198147af1dc9a93272a719f3108b2a64de
write.csv(valid2,'validation.csv', row.names=FALSE)

