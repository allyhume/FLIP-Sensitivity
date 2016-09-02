# Processes the baseline data over the whole grid

setwd('/Users/ahume/datasync/FLIP/SensitivityAnalysis/data/simulationResults/aprilAllGrid')

# returns (time, freshWeight, leafNumber, hasEmerged)
parseRawDataLine <- function(line) {
  
  parts = strsplit(line,split="(:|,)")[[1]]
  df <- data.frame(as.numeric(parts[2]))
  colnames(df) <- c("time")
  df$rosetteWeight <- as.numeric(parts[6])
  df$leafNumber    <- as.numeric(parts[14])
  df$hasEmerged    <- as.numeric(parts[26])
  return(df)
}

# returns (floweringTime, freshWeightAtFlowering, leafNumberAtFlowering, hasEmerged, eme)
getFinalDataFromRawDataFile <- function(fileName) {
  f  <- file(fileName, open = "r")
  lastLine <- ""
  eme <- -1
  while (length(oneLine <- readLines(f, n = 1, warn = FALSE)) > 0) {
    r <- parseRawDataLine(oneLine)
    if (r$hasEmerged[1] == 1 && eme == -1) eme <- r$time[1] 
    if (oneLine != "Finished") lastLine = oneLine
  } 
  close(f)
  
  df <- parseRawDataLine(lastLine);
  df$eme = eme;
  colnames(df) <- c("floweringTime", "freshWeightAtFlowering", "leafNumberAtFlowering", "hasEmerged", "eme")
  
  return(df)
}

# Returns the data after n hours of growth
# returns (time, freshWeight, leafNumber)
getNHourDataFromRawDataFile <- function(fileName,nHour) {
  f  <- file(fileName, open = "r")
  lastLine <- ""
  eme <- -1
  while (length(oneLine <- readLines(f, n = 1, warn = FALSE)) > 0) {
    r <- parseRawDataLine(oneLine)
    if (r$hasEmerged[1] == 1 && eme == -1) eme <- r$time[1] 
    if (r$hasEmerged[1] && r$time[1] == eme + nHour ) {
      lastLine = oneLine;
      break;
    }
  } 
  close(f)
  
  df <- parseRawDataLine(lastLine);
  df$eme = eme;
  
  return(df)
}


readLatLonFile <- function(latLonFile) {
  return( read.csv(latLonFile,sep=" "))
}

getParameterFromResultFileName <- function(resultFile) {
  return(as.numeric(gsub("res.*csv","",resultFile)))
}

getFloweringTimeData <- function() {
  # Start with lat and lon
  data <- NULL
  lat_lon_file_list <- list.files(pattern="lat_lon*")
  for( lat_lon_file in lat_lon_file_list) {
    
    print(lat_lon_file)
    
    # Read in the lat and lon
    lat_lon <- readLatLonFile(lat_lon_file)
    
    pattern <- paste(gsub("lat_lon","result",lat_lon_file),".+",sep="")
    result_file_list <- list.files(pattern=pattern)
    for (result_file in result_file_list) {
      
      print(result_file)
      
      result_data <- getFinalDataFromRawDataFile(result_file)
      result_data$lat <- lat_lon$lat[1]
      result_data$lon <- lat_lon$lon[1]
      result_data$param <- getParameterFromResultFileName(result_file)
      
      if (is.null(data)) data <- result_data
      else data <- rbind(data, result_data)        
    }
  }
  return(data)
}

getNHoursGrowthData <- function(nHours) {
  # Start with lat and lon
  data <- NULL
  lat_lon_file_list <- list.files(pattern="lat_lon*")
  for( lat_lon_file in lat_lon_file_list) {
    
    print(lat_lon_file)
    
    # Read in the lat and lon
    lat_lon <- readLatLonFile(lat_lon_file)
    
    pattern <- paste(gsub("lat_lon","result",lat_lon_file),".+",sep="")
    result_file_list <- list.files(pattern=pattern)
    for (result_file in result_file_list) {
      
      print(result_file)
      
      result_data <- getNHourDataFromRawDataFile(result_file,nHours)
      result_data$lat <- lat_lon$lat[1]
      result_data$lon <- lat_lon$lon[1]
      result_data$param <- getParameterFromResultFileName(result_file)
      
      if (is.null(data)) data <- result_data
      else data <- rbind(data, result_data)        
    }
  }
  return(data)
}

floweringTimeData <- getFloweringTimeData()

# Calculate growing time
floweringTimeData$growingTime <- floweringTimeData$floweringTime - floweringTimeData$eme

# Get mimimum growing time
minGrowingTime <- min(floweringTimeData$growingTime)-24

# Get the data at minGrowingTime
nHoursGrowthData <- getNHoursGrowthData(minGrowingTime)

# Scatter plot of Fresh Weight to growing time
# This shows that we have some plants that are growing on a different trajectory
plot(floweringTimeData$growingTime/24, floweringTimeData$freshWeightAtFlowering,xlab="Growing time (days)",ylab="Fresh weight at flowering (g)",main="April planting")

# Plotting on a log scale shows two district groups and we can draw a line between them
plot(floweringTimeData$growingTime/24, floweringTimeData$freshWeightAtFlowering,xlab="Growing time (days)",ylab="Fresh weight at flowering (g)",main="April planting (log scale for weight)",log="y")
good <- floweringTimeData[ 0.38*(floweringTimeData$growingTime/24) -8.5> log(floweringTimeData$freshWeightAtFlowering),]
bad  <- floweringTimeData[ 0.38*(floweringTimeData$growingTime/24) -8.5 <= log(floweringTimeData$freshWeightAtFlowering),]
points(good$growingTime/24, good$freshWeightAtFlowering,col="blue")
points(bad$growingTime/24,  bad$freshWeightAtFlowering,col="red")

# Where are these points geographically?
library(ggmap)
library(mapproj)
map <- get_map(location = 'Europe', zoom = 3)
ggmap(map)  +
  geom_point(aes(x = lon, y = lat), data = good,   alpha = 1, color='blue',  size=5) +
  geom_point(aes(x = lon, y = lat), data = bad,    alpha = 1, color='red',   size=5) +
  ggtitle("Blue - model works, Red - out of model range")

# There is a very clear split on latitude above and below 60 so we filter on that
floweringTimeData <- floweringTimeData[floweringTimeData$lat < 60,]
nHoursGrowthData  <- nHoursGrowthData[nHoursGrowthData$lat < 60,]

# Now we can draw some plots of the data over a range of locations

# Plot flowering time
floweringTimeData$floweringTimeDays <- floweringTimeData$floweringTime/24
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=floweringTimeDays), data = floweringTimeData, alpha = 1, size=5) +
  scale_colour_gradientn(colours=rainbow(4)) +
  ggtitle("Flowering time (days)")

# Plot number of leaves at flowering time
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=leafNumberAtFlowering), data = floweringTimeData, alpha = 1, size=5) +
  scale_colour_gradientn(colours=rainbow(4)) +
  ggtitle("Leaf number at flowering")

# Plot rosette mass (fresh weight) at flowering time
ggmap(map)  +
  scale_colour_gradientn(colours=rainbow(4)) +
  geom_point(aes(x = lon, y = lat, color=freshWeightAtFlowering), data = floweringTimeData, alpha = 1, size=5) +
  ggtitle("Rossette mass (fresh weight (g))\n at flowering time")

# Plot growing time
floweringTimeData$growingTimeDays <- floweringTimeData$growingTime/24
ggmap(map)  +
  scale_colour_gradientn(colours=rainbow(4)) +
  geom_point(aes(x = lon, y = lat, color=growingTimeDays), data = floweringTimeData, alpha = 1, size=5) +
  ggtitle("Growing time (days)")

# Plot rosette mass after n days
ggmap(map)  +
  scale_colour_gradientn(colours=rainbow(4)) +
  geom_point(aes(x = lon, y = lat, color=rosetteWeight), data = nHoursGrowthData, alpha = 1, size=5) +
  ggtitle(paste("Rosette mass (fresh weight (g))\n after",sprintf("%.2f",minGrowingTime/24),"days"))


