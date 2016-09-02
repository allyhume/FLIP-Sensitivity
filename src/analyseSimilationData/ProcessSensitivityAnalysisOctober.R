# Processes the October sensitivity data

setwd('/Users/ahume/datasync/FLIP/SensitivityAnalysis/data/processedSimulationData/octoberSensitivity')

sensitivityData <- read.csv(file='sensitivityApril.csv')

minGrowingTime <- 373

# Set up map properties
library(ggmap)
library(mapproj)
map <- get_map(location = 'Europe', zoom = 3)

# Simple plot of locations used for the sensitivity study
ggmap(map)  +
  geom_point(aes(x = lon, y = lat), data = sensitivityData,    alpha = 1, color='blue',   size=4) +
  ggtitle("Locations used for sensitivity study")


# Now have the sensitivity data we can do things with it

# Sensivity for a fixed location (lat=47.25,lon=10.50) with respect to floweringTime
data <- sensitivityData[sensitivityData$lon==10.5,]
plot(data$param,data$floweringTimeSens/data$baseFloweringTime*100,ylab="percentage change in flowering time",xlab="parameter id",main="Sensitivity wrt flowering time\nat (lat=47.25,lon=10.5)")

# Sensivity for a fixed location (lat=47.25,lon=10.50) with respect to growingTime
data <- sensitivityData[sensitivityData$lon==10.5,]
plot(data$param,data$growingTimeSens/data$baseGrowingTime*100,ylab="percentage change in growing time",xlab="parameter id",main="Sensitivity wrt growing time\nat (lat=47.25,lon=10.5)")

# Sensitivity for a fixed location (lat=47.25,lon=10.50) with respect to rosette mass a n Hours
data <- sensitivityData[sensitivityData$lon==10.5,]
plot(data$param,data$rosetteWeightSens/data$baseRosetteWeight*100,ylab="percentage change in rosette mass",xlab="parameter id",main=paste("Sensitivity wrt rosette mass (g)\nafter",sprintf("%.2f",minGrowingTime/24),"days at (lat=47.25,lon=10.5)"))

# Sensitivity for a fixed location (lat=47.25,lon=10.50) with respect to leaf number at flowering
data <- sensitivityData[sensitivityData$lon==10.5,]
plot(data$param,data$leafNumberAtFloweringSens/data$baseLeafNumberAtFlowering*100,ylab="percentage change in leaf number",xlab="parameter id",main=paste("Sensitivity wrt leaf number at flowering\nat (lat=47.25,lon=10.5)"))

# Now plot all together
# Sensivity with respect to floweringTime
data <- sensitivityData
plot(data$param,data$floweringTimeSens/data$baseFloweringTime*100,ylab="percentage change in flowering time",xlab="parameter id",main="Sensitivity wrt flowering time",pch=20)

# Sensivity with respect to growingTime
data <- sensitivityData
plot(data$param,data$growingTimeSens/data$baseGrowingTime*100,ylab="percentage change in growing time",xlab="parameter id",main="Sensitivity wrt growing time",pch=20)

# Sensitivity with respect to rosette mass at n Hours
data <- sensitivityData
plot(data$param,data$rosetteWeightSens/data$baseRosetteWeight*100,ylab="percentage change in rosette mass",xlab="parameter id",main=paste("Sensitivity wrt rosette mass (g)\nafter",sprintf("%.2f",minGrowingTime/24),"days"),pch=20)

# Sensitivity for a fixed location  with respect to leaf number at flowering
data <- sensitivityData
plot(data$param,data$leafNumberAtFloweringSens/data$baseLeafNumberAtFlowering*100,ylab="percentage change in leaf number",xlab="parameter id",main=paste("Sensitivity wrt leaf number\n at flowering"))

# Zooming in on the rosette mass figure:
data <- sensitivityData
plot(data$param,data$rosetteWeightSens/data$baseRosetteWeight*100,ylab="percentage change in rosette mass",xlab="parameter id",main=paste("Sensitivity wrt rosette mass (g)\nafter",sprintf("%.2f",minGrowingTime/24),"days"),xlim=c(0,75),pch=20)

# What are the top sensitivities with respect to rosette mass at 15.5 days?
# Need to take max of abs value grouped by param
data <- data.table(sensitivityData)

# What parameters have sensitivity values greater than 2% with respect to the flowering time:
data <- data.table(sensitivityData)
data <- data[,max(abs(floweringTimeSens/baseFloweringTime*100)),by=param]
data <- data[V1 > 2,]
data[order(-V1)]

# What parameters have sensitivity values greater than 2% with respect to the growing time:
data <- data.table(sensitivityData)
data <- data[,max(abs(growingTimeSens/baseGrowingTime*100)),by=param]
data <- data[V1 > 2,]
data[order(-V1)]

# What parameters have sensitivity values greater than 2% with respect to the leaf number:
data <- data.table(sensitivityData)
data <- data[,max(abs(leafNumberAtFloweringSens/baseLeafNumberAtFlowering*100)),by=param]
data <- data[V1 > 2,]
data[order(-V1)]


# What parameters have sensitivity values greater than 2% with respect to the rosette mass at 15.5 days:
data <- data.table(sensitivityData)
data <- data[,max(abs(rosetteWeightSens/baseRosetteWeight*100)),by=param]
data <- data[V1 > 2,]
data[order(-V1)]

library(ggmap)
library(mapproj)
map <- get_map(location = 'Europe', zoom = 3)

# Parameter 52
data <- sensitivityData[sensitivityData$param==52,]
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=rosetteWeightSens/baseRosetteWeight*100), data = data, alpha = 1, size=5) +
  scale_colour_gradientn("sensitivity",colours=rainbow(4)) +
  ggtitle("Parameter 52 sensitivity\nwrt rosette mass after 15.54 days")

# Parameter 19
data <- sensitivityData[sensitivityData$param==19,]
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=rosetteWeightSens/baseRosetteWeight*100), data = data, alpha = 1, size=5) +
  scale_colour_gradientn("sensitivity",colours=rainbow(4)) +
  ggtitle("Parameter 19 sensitivity\nwrt rosette mass after 15.54 days")

# Parameter 1
data <- sensitivityData[sensitivityData$param==1,]
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=rosetteWeightSens/baseRosetteWeight*100), data = data, alpha = 1, size=5) +
  scale_colour_gradientn("sensitivity",colours=rainbow(4)) +
  ggtitle("Parameter 1 sensitivity\nwrt rosette mass after 15.54 days")

# Parameter 44
data <- sensitivityData[sensitivityData$param==44,]
ggmap(map)  +
  geom_point(aes(x = lon, y = lat, color=rosetteWeightSens/baseRosetteWeight*100), data = data, alpha = 1, size=5) +
  scale_colour_gradientn("sensitivity",colours=rainbow(4)) +
  ggtitle("Parameter 44 sensitivity\nwrt rosette mass after 15.54 days")










