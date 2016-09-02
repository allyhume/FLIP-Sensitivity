These directories contain the scripts to run the simulations.

The simulations are run by running:
```
runModel.bash
```

Before running you will need to change the following two lines at the top of the script
to point to the correct location of the framework model and the processed weather
data:
```
FILES=/Users/ahume/FLIP/SensitivityAnalysis/data/processedWeather/lat_lon_2010_*.csv
FRAMEWORK_MODEL_DIR=/Users/ahume/FLIP/FrameworkModel
```

The April scripts attempt to process all the lat_lon_2010_*.csv files it can find
while the October scripts attempt to process all the lat_lon_2010-2011_*.csv files
it can find.

When running the all grid scripts then processing all the lat_lon files it can 
find is a fine thing to do.  When doing the sensitivity analysis this will take a
very very long time.  To limit the number of files processed when running the
sensitivity analysis move some of the lat_lon files corresponding to locations
you do not wish to process out of the way (e.g. move them to a hide directory).

The sensitivity analysis work carried out used only 15 locations.  For the April
sensitivity analysis the lat_lon files were:
```
lat_lon_2010_151_271.csv	lat_lon_2010_301_211.csv	lat_lon_2010_451_151.csv
lat_lon_2010_181_271.csv	lat_lon_2010_331_211.csv	lat_lon_2010_481_151.csv
lat_lon_2010_211_241.csv	lat_lon_2010_361_181.csv	lat_lon_2010_511_151.csv
lat_lon_2010_241_241.csv	lat_lon_2010_391_181.csv	lat_lon_2010_541_121.csv
lat_lon_2010_271_211.csv	lat_lon_2010_421_181.csv	lat_lon_2010_571_121.csv
```

For the October sensitivity work the lat_lon files were:
```
lat_lon_2010-2011_151_271.csv	lat_lon_2010-2011_301_211.csv	lat_lon_2010-2011_451_151.csv
lat_lon_2010-2011_181_271.csv	lat_lon_2010-2011_331_211.csv	lat_lon_2010-2011_481_151.csv
lat_lon_2010-2011_211_241.csv	lat_lon_2010-2011_361_181.csv	lat_lon_2010-2011_511_151.csv
lat_lon_2010-2011_241_241.csv	lat_lon_2010-2011_391_181.csv	lat_lon_2010-2011_541_121.csv
lat_lon_2010-2011_271_211.csv	lat_lon_2010-2011_421_181.csv	lat_lon_2010-2011_571_121.csv
```

