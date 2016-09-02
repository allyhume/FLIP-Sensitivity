This directory contains the scripts to process the simulation result data.

These scripts process data such as these in the data/simulationResults and
data/processedSimulationData subdirectories.

Before running any of these scripts change the path of the setwd command at near the top to
point to the appropriate directory.

ProcessBaseDataApril.R
----------------------

Processes whole grid April data and produces the plots and data show on the report
wiki page.


ProcessBaseDataOctober.R
------------------------

Processes whole grid October data and produces the plots and data show on the report
wiki page.


PreProcessSensitivityAnalysisApril.R	
------------------------------------

Preprocesses the April sensitivity data to produce data in the 
data/processedSimulationData/aprilSensitivity directory.  

Note the result of running this already exists this repository so you should only 
need to run this if you have altered these results in some way.


PreProcessSensitivityAnalysisOctober.R	
------------------------------------

Preprocesses the October sensitivity data to produce data in the 
data/processedSimulationData/octoberSensitivity directory.

Note the result of running this already exists this repository so you should only 
need to run this if you have altered these results in some way.


ProcessSensitivityAnalysisApril.R
---------------------------------

Uses the output from PreProcessSensitivityAnalysisApril.R to produce the plots
and data included in the report.


ProcessSensitivityAnalysisApril.R
---------------------------------

Uses the output from PreProcessSensitivityAnalysisOctover.R to produce the plots
and data included in the report.

