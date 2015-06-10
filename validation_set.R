#!/usr/bin/RScript

require(rjson)
require(data.table)
require(ggplot2)

train <- read.csv("data/train.csv")
train <- data.table(train)

##
train <- train[MISSING_DATA!='True']
train <- train[POLYLINE!='[]']
setkey(train, TRIP_ID)

##
train[, TIMESTAMP:=(as.POSIXct(as.integer(TIMESTAMP), origin="1970-01-01", tz='GMT'))]
train[, sample_date:=as.Date(TIMESTAMP)]

## the same days as in test set but for 2013
dates <- c("2013-08-14", "2013-09-30", "2013-10-06", "2013-11-01" , "2013-12-21")
valid <- valid[sample_date %in% dates]



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
test[, SNAPSHOTS:=length(fromJSON(POLYLINE)), by=TRIP_ID]
test[, duration_snapshots:=SNAPSHOTS*15/60]
##
ggplot(test) + geom_histogram(aes(x=duration_snapshots), binwidth=5) + theme_bw()



##
test[, CUTOFF:=max(TIMESTAMP), by=sample_date]
test[, duration_timestamp:=as.numeric(CUTOFF-TIMESTAMP)/60]


