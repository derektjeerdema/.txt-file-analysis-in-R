#Analyzing Data Collected From .txt Files

#Reading in and analyzing cloud and temperature data from .txt files

#For this project, I had to read in 7 different variables relating to atmospheric temperature, each with 72 timepoint locations. The variables are stored in .txt files and were loaded into R and seperated into 4 different columns. The variables are low clouds, mid clouds, high clouds, ozone, pressure, surface temperature and temeprature. The columns will show latitude, longitude, value of variable, and time taken 

setwd("C:/Users/Der-chan/Documents/STA 141/NASA")
library(reshape2)
txtfiles=list.files(pattern="*.txt")

ffs=lapply(txtfiles,function(f){
  paste0(f)
  x=read.table(f,skip=7,strip.white=T)
  x=x[-(2:3)]
  date=scan(f,skip=4,nlines=1,what=character())[3]
  long=scan(f,skip=5,nlines=2,what=character())[1:24]
  colnames(x)=c("lat",long)
  ff=melt(x,id.vars="lat",variable.name="long")
  ff$date=date
  ff
})


#This function retrieves all values from .txt files in the specified directory. From this I have 504 (72 .txt files for 7 variables) different elements. Now its time to split them up into individual variables.


cloudhigh = do.call(rbind, ffs[1:72]) #numbers for the next variable start every 72 .txt files
cloudlow = do.call(rbind, ffs[73:144])
cloudmid = do.call(rbind, ffs[145:216])
ozone = do.call(rbind, ffs[217:288])
pressure = do.call(rbind, ffs[289:360])
surftemp = do.call(rbind, ffs[361:432])
temperature = do.call(rbind, ffs[433:504])


#An example of the completed data frame

summary(cloudhigh)
head(cloudhigh)



#Step 2

#For this part I needed to check and see if the 7 variables correspond to points on the same grid, in the same order. The "identical" function checks this for me, and shows whether the points are identical or not. For this data to all correspond, Latitude, longitude, and time need to all be equal accross all 7 datasets.


identical(paste(cloudhigh$lat, cloudhigh$long, cloudhigh$date), paste(cloudlow$lat, cloudlow$long, cloudlow$date))
identical(paste(cloudmid$lat, cloudmid$long, cloudmid$date), paste(cloudlow$lat, cloudlow$long, cloudlow$date))
identical(paste(cloudmid$lat, cloudmid$long, cloudmid$date), paste(ozone$lat, ozone$long, ozone$date))
identical(paste(pressure$lat, pressure$long, pressure$date), paste(ozone$lat, ozone$long, ozone$date))
identical(paste(pressure$lat, pressure$long, pressure$date), paste(surftemp$lat, surftemp$long, surftemp$date))
identical(paste(temperature$lat, temperature$long, temperature$date), paste(surftemp$lat, surftemp$long, surftemp$date))




#Since they all came up as "TRUE", I can conclude that all 7 variables correspond to the same dataset. The next step would be to combine all 7 variables into 1 dataframe. This dataframe will have 7 columns for each of the variables, and an extra 3 for latitude, longitude and time, for a total of 10 variables.


library("plyr")
clouddata = cbind(cloudlow$value, cloudmid$value, cloudhigh$value, ozone$value, pressure$value, surftemp$value, temperature)
clouddata =  rename(clouddata, c("cloudlow$value"= "cloudlow" , "cloudmid$value" = "cloudmid", "cloudhigh$value" = "cloudhigh", "ozone$value" = "ozone", "pressure$value" = "pressure", "surftemp$value" = "surftemp", "value" = "temperature"))

head(clouddata)

#An extra file with elevation is also needed. This file is loaded seperately due to it ending in a ".dat", which is because it is time-insensitive.



#reads "intlvtn.dat" and shows values in the sequence
setwd("C:/Users/Der-chan/Documents/STA 141/NASA")
elevation = readLines("intlvtn.dat")
elevation = unlist(strsplit(elevation[2:25]," "))
newelevation = elevation [-seq(1,576,25)]

#remove the selected sequence

newelevation = (as.vector(as.numeric(newelevation)))
elevation = rep(newelevation, times = 72)

#fits elevation for our dataset and names it

clouddata["elevation"] <- NA
clouddata$elevation <- as.numeric(elevation)
head(clouddata)




#From this head() function we can see "elevation" was loaded and incorporated successfully



#transform value to numeric for qplot
clouddata[,1:6]= as.numeric(as.character(unlist(clouddata[,1:6])))

#use ggplot to make the graph
library(ggplot2)
qplot(data = clouddata, x = clouddata$temperature, y = clouddata$pressure, color = clouddata$cloudlow, main = "Pressure vs Temperature With Percent of Low Clouds", xlab = "Temperature", ylab = "Pressure" ) + scale_color_gradient(low = "blue", high = "red")



#Display the average value for pressure on a map.


clouddata$lat = as.character(clouddata$lat)
clouddata$lat = substr(clouddata$lat,1,nchar(clouddata$lat)-1)
clouddata$lat = as.numeric(clouddata$lat)

clouddata$long = as.character(clouddata$long)
clouddata$long = substr(clouddata$long,1,nchar(clouddata$long)-1)
clouddata$long = as.numeric(clouddata$long)



pm = with(clouddata, by(clouddata$pressure, list(-long, lat), mean))

dn = dimnames(pm)
x = as.numeric(dn[[1]])
y = as.numeric(dn[[2]])

image(x, y, pm, xlab = "longitude", ylab = "latitude")

library(maps)
map(xlim = range(x),  ylim = range(y), add = TRUE)




```







