Raw weather data as obtained from Luke Smallman in the School of Geosciences.

There is one file for each value (min, max and mean daily temperature and 
mean daily PAR) for each month.  We have data for 2010 and 2011.

You will need to unzip these files before processing them.

The grid used to produce these files is at a very fine granularity which
is why these files are so large.  In practice we subsampled this grid
to get just 1 in every 30 points in each dimension so we got one in every
900 grid points.

You can use 'ncdump -h' to look at the headers of these files for more
details.

These files were processed using the scripts and code in src/weatherGenerator
and the resulting output files can be found in data/processedWeather.


