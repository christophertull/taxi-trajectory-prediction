HaversineDistance=function(lat1,lon1,lat2,lon2)
{

	#returns the distance in km
	REarth<-6371
	lat<-abs(lat1-lat2)*pi/180
	lon<-abs(lon1-lon2)*pi/180
	lat1<-lat1*pi/180
	lat2<-lat2*pi/180
	a<-sin(lat/2)*sin(lat/2)+cos(lat1)*cos(lat2)*sin(lon/2)*sin(lon/2)
	d<-2*atan2(sqrt(a),sqrt(1-a))
	d<-REarth*d

	return(d)
	
}

RMSE<-function(pre,real)
{
	return(sqrt(mean((pre-real)*(pre-real))))
}

meanHaversineDistance<-function(lat1,lon1,lat2,lon2)
{
	return(mean(HaversineDistance(lat1,lon1,lat2,lon2)))
}

#USAGE
#
#FUNCTION PARAMETERS: @submission,@answers
#@submission: path+filename containing the answers to submit in CSV format
#@answers: path+filename containing the answers to evaluate the submission in CSV format
travelTime.PredictionEvaluation<-function(submission,answers)
{
	dt<-read.csv(submission)
	tt_sub<-dt[,2]
	dt<-read.csv(answers)
	tt_real<-dt[,2]
	return (RMSE(tt_sub,tt_real))
}

#USAGE
#
#FUNCTION PARAMETERS: @submission,@answers
#@submission: path+filename containing the answers to submit in CSV format
#@answers: path+filename containing the answers to evaluate the submission in CSV format
destinationMining.Evaluation<-function(submission,answers)
{
	dt<-read.csv(submission)
	lat_sub<-dt[,2]
	lon_sub<-dt[,3]
	dt<-read.csv(answers)
	lat_real<-dt[,2]
	lon_real<-dt[,3]
	return (meanHaversineDistance(lat_sub,lon_sub,lat_real,lon_real))
}