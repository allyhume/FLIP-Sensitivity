setwd("/home/ahume/WeatherData/met_drivers_europe")

# sample rate 
# Want to output data for every n values in each dimension
sampleRate <- 30

library(ncdf4)
library(abind)

readMonth <- function(fileStem,year,month,variable) {
    
  ncdfData <- nc_open(paste(fileStem,year,month,".nc", sep=""))
  return(ncvar_get(ncdfData, variable))
}

readYear <- function(fileStem,year,variable) {
  
  months <- c("02","03","04","05","06","07","08","09","10","11","12")
  
  result <- readMonth(fileStem,year,"01",variable);
  
  for (month in months) {
    monthData <- readMonth(fileStem,year,month,variable)
    result <- abind(result,monthData,along=3)
  }
  return(result)
}

year <- "2011"
airt_min  <- readYear("airt_daily_min_",  year, "airt_min")
airt_max  <- readYear("airt_daily_max_",  year, "airt_max")
airt_mean <- readYear("airt_daily_mean_", year, "airt_mean")
par_mean  <- readYear("par_daily_mean_",  year, "daily_par")

# Read any data file to get some metadata
metadata = nc_open("airt_daily_max_201101.nc")
lon = ncvar_get(metadata, "Longitude")
lat = ncvar_get(metadata, "Latitude")


# Sample the lat and lon as there are too many points to plot on graph 
# land <- par_mean[seq(1, length(lon), 5), seq(1, length(lat), 5), 1]
# lon <- lon[seq(1, length(lon), 5)]
# lat <- lat[seq(1, length(lat), 5)]
# land <- c(land)

# Draw a map to see where out points are located
#library(ggmap)
#library(mapproj)
#map <- get_map(location = 'Europe', zoom = 4)

# need to get lat and lon into a table
# locations <- merge(lon,lat)
# colnames(locations) <- c("lon","lat")
# locations$land <- !is.na(land)
# locations <- locations[locations$land,]
# ggmap(map) + geom_point(aes(x = lon, y = lat), data = locations, alpha = .5)

# Call the weather generator for a specific location
# 1, 1 is a location with data so lets start with that...
metadata = nc_open("airt_daily_max_201101.nc")
lon = ncvar_get(metadata, "Longitude")
lat = ncvar_get(metadata, "Latitude")

dyn.load("/home/ahume/WeatherData/weather_generator_src/weather_generator.so")

for (x in seq(1,length(lon),sampleRate) ) {
    for (y in seq(1,length(lat),sampleRate) ) {

    	print(lon[x])
	print(lat[y])

	swrad_in    <- par_mean[x,y,]
	sat_min_in  <- airt_min[x,y,]-273.15
	sat_max_in  <- airt_max[x,y,]-273.15
	sat_avg_in  <- airt_mean[x,y,]-273.15

	if (!is.na(swrad_in[1])) { 
	   # Now we need to put this into the weather generator..
	   nos_days <- length(sat_min_in)
	   latitude <- rep(lat[y],nos_days)
	   days_in_yr <- 365.25
	   time <- seq(1,nos_days)
	   #   some dummy data arrays
	   ppt_in    <- rep(0, nos_days)
	   coa_in    <- rep(0, nos_days)
	   rh_avg_in <- rep(0, nos_days)                                                                       
	   rh_max_in <- rep(0, nos_days)
	   rh_min_in <- rep(0, nos_days)
	   wind_in   <- rep(0, nos_days)

	   # call function
	   tmp=.Fortran("weathergeneratorinterface",
		     latitude=as.single(latitude),
             	     nos_days=as.integer(length(time)),
             	     days_in_yr=as.single(days_in_yr)
             	     ,time=as.single(time)
             	     ,sat_avg_in=as.single(sat_avg_in),sat_max_in=as.single(sat_max_in),sat_min_in=as.single(sat_min_in)
             	     ,ppt_in=as.single(ppt_in),swrad_in=as.single(swrad_in),coa_in=as.single(coa_in)
             	     ,rh_avg_in=as.single(rh_avg_in),rh_max_in=as.single(rh_max_in),rh_min_in=as.single(rh_min_in),wind_in=as.single(wind_in)
             	     ,sat_out=as.single(array(0,dim=c(length(sat_avg_in)*24))),ppt_out=as.single(array(0,dim=c(length(sat_avg_in)*24)))
             	     ,swrad_out=as.single(array(0,dim=c(length(sat_avg_in)*24))),coa_out=as.single(array(0,dim=c(length(sat_avg_in)*24)))
             	     ,rh_out=as.single(array(0,dim=c(length(sat_avg_in)*24))),wind_out=as.single(array(0,dim=c(length(sat_avg_in)*24))) )

	   # extract wanted output
	   sat_out=tmp$sat_out ; ppt_out=tmp$ppt_out
	   coa_out=tmp$coa_out ; swrad_out=tmp$swrad_out
	   rh_out=tmp$rh_out   ; wind_out=tmp$wind_out

	   # Need to the light data (swrad) from W.m-2 to micromol.m-2.s-1.  For details of this
	   # convertion see: http://www.egc.com/useful_info_lighting.php.  The conversion rate is
	   # 4.57
	   swrad_out <- swrad_out*4.57

	   # Write data to file...
	   df <- data.frame(lat[y],lon[x])
	   colnames(df) <- c("lat","lon")
    	   write.table(df,        file=paste("lat_lon_2011_",x,"_",y,".csv",sep=""),row.names=FALSE)
	   write.table(sat_out,   file=paste("airt_2011_",x,"_",y,".csv",sep=""),   row.names=FALSE)
	   write.table(swrad_out, file=paste("swrad_2011_",x,"_",y,".csv",sep=""),  row.names=FALSE)
	 }
    }
}

# unload the object
dyn.unload("/home/ahume/WeatherData/weather_generator_src/weather_generator.so")
rm(tmp) ; gc()
