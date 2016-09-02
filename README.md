# FLIP-Sensitivity

This repository stores the scripts and data associated with the Framework model sensitivity analysis work.

The results are documented on the wiki site: https://www.wiki.ed.ac.uk/display/AHFF/Framework+model+sensitivity+analysis+report

This repository stores the original raw environmental data as well as the data produced by each of the stages and also the scripts required to run these stage should you wish to reproduce the data.  To run the simulations required a version of the framework model. The version used in this study can be found in: https://github.com/allyhume/FLIP-Sensitivity-FrameworkModel

The work starts with environmental data obtained from ECMWF's ERA interim data. The raw data is in data/rawWeather.

To process this raw data into the hourly weather data need by the framework model we use the code in src/weatherGenerator.

This produces the data found in data/processedWeather.

We can then run the various simulation scripts found in the subdirectories of src/runSimulation. These can run all grid studies or sensitivity studies you will probably wish to run on a subset of the grid locations.

The output of running these simulations can be found in sub-directories of data/simulationResults. The result file names are appended by a number that indicates which parameter has been altered for that simulation.  These numbers range form 1 to 207 for each of the parameters. If the file name is appended by 0 then no parameter values have been changed and it is the basal result.

The results can be used to produce the plots and data in the report by running the R scripts found in src/analyseSimilationData directory.


Ally Hume

2 September 2016
