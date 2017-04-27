The R scripts take the various *.nc data files as supplied by Luke Smallman and produce the hourly data that we need.

Before running you will need to compile the weather generator code with:
```
R CMD SHLIB -o weather_generator.so weather_generator.f90 wg_interface.f90
```
You will need to ensure R has the following packages installed before running:
```
install.packages("ncdf4")
install.pacakges("abind")
```
You will also need to edit the setwd line near to the top of the scripts to
specify the location of the *.nc files.

The 2011 version (SampleAndProduceData2011.R) will read in the following nc data files:
```
airt_daily_max_201101.nc   airt_daily_mean_201105.nc  airt_daily_min_201109.nc
airt_daily_max_201102.nc   airt_daily_mean_201106.nc  airt_daily_min_201110.nc
airt_daily_max_201103.nc   airt_daily_mean_201107.nc  airt_daily_min_201111.nc
airt_daily_max_201104.nc   airt_daily_mean_201108.nc  airt_daily_min_201112.nc
airt_daily_max_201105.nc   airt_daily_mean_201109.nc  par_daily_mean_201101.nc
airt_daily_max_201106.nc   airt_daily_mean_201110.nc  par_daily_mean_201102.nc
airt_daily_max_201107.nc   airt_daily_mean_201111.nc  par_daily_mean_201103.nc
airt_daily_max_201108.nc   airt_daily_mean_201112.nc  par_daily_mean_201104.nc
airt_daily_max_201109.nc   airt_daily_min_201101.nc   par_daily_mean_201105.nc
airt_daily_max_201110.nc   airt_daily_min_201102.nc   par_daily_mean_201106.nc
airt_daily_max_201111.nc   airt_daily_min_201103.nc   par_daily_mean_201107.nc
airt_daily_max_201112.nc   airt_daily_min_201104.nc   par_daily_mean_201108.nc
airt_daily_mean_201101.nc  airt_daily_min_201105.nc   par_daily_mean_201109.nc
airt_daily_mean_201102.nc  airt_daily_min_201106.nc   par_daily_mean_201110.nc
airt_daily_mean_201103.nc  airt_daily_min_201107.nc   par_daily_mean_201111.nc
airt_daily_mean_201104.nc  airt_daily_min_201108.nc   par_daily_mean_201112.nc
```

And will output three files for each of the sampled locations, e.g.:
airt_2011_421_151.csv  lat_lon_2011_421_151.csv  swrad_2011_421_151.csv

These files contain the year long air temperature and short wave radiation 
data for each hour the year 2011. The data corresponds to longitude index 
421 and latitude index 151 into the grid of data points in the *.nc files.
The actual latitude and longitude values are output in the corresponding
lat_lon_2011_421_151.csv file.
