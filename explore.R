
df <- read.csv("train.csv")

top.callers <- sort(table(df$ORIGIN_CALL), decreasing=TRUE)
sum(top.callers > 10)/length(top.callers)
