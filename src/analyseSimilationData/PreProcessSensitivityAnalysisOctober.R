# Pre-processes the October sensitivity data

library(data.table)

setwd('/Users/ahume/datasync/FLIP/SensitivityAnalysis/data/simulationResults/octoberSensitivity')

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

# Use the same minimum growing time as was obtained from April all Europe data
minGrowingTime <- 373

# Get the data at minGrowingTime
nHoursGrowthData <- getNHoursGrowthData(minGrowingTime)

# Need to calculate the differences from basal 

#    Split into basal and non-basal data frames
basalfloweringTimeData <- floweringTimeData[floweringTimeData$param==0,]
colnames(basalfloweringTimeData) <- c("baseFloweringTime", "baseFreshWeightAtFlowering","baseLeafNumberAtFlowering","baseHasEmerged","baseEme","baseLat","baseLon","baseParam","baseGrowingTime")
floweringTimeData <- floweringTimeData[floweringTimeData$param!=0,]

basalNHoursGrowthData <- nHoursGrowthData[nHoursGrowthData$param==0,]
colnames(basalNHoursGrowthData) <- c("baseTime","baseRosetteWeight","baseLeafNumber","baseHasEmerged","baseEme","baseLat","baseLon","baseParam")
nHoursGrowthData <- nHoursGrowthData[nHoursGrowthData$param!=0,]

#    Join the two data frames on lat and lon (actually as we have unique longitudes then that is enough here)
floweringTimeData <- merge(x=floweringTimeData, y=basalfloweringTimeData, by.x=c("lat","lon"), by.y=c("baseLat","baseLon"))
nHoursGrowthData <- merge(x=nHoursGrowthData, y=basalNHoursGrowthData, by.x=c("lat","lon"), by.y=c("baseLat","baseLon"))

#    Calculate the differences from basal
floweringTimeData$floweringTimeSens         <- floweringTimeData$floweringTime         - floweringTimeData$baseFloweringTime
floweringTimeData$growingTimeSens           <- floweringTimeData$growingTime           - floweringTimeData$baseGrowingTime
floweringTimeData$leafNumberAtFloweringSens <- floweringTimeData$leafNumberAtFlowering - floweringTimeData$baseLeafNumberAtFlowering
nHoursGrowthData$rosetteWeightSens          <- nHoursGrowthData$rosetteWeight          - nHoursGrowthData$baseRosetteWeight

# Reduce the nHoursGrowthData to just the columns we need
nHoursGrowthData <- nHoursGrowthData[,c("lat","lon","param","rosetteWeight","baseRosetteWeight","rosetteWeightSens")]

# Comine into one data frame and save it
sensitivityData <- merge(x=floweringTimeData, y=nHoursGrowthData, by=c("lat","lon","param"))

write.csv(file="sensitivityOctober.csv", sensitivityData, row.names = FALSE)



