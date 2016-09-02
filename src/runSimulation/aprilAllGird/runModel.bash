#!/bin/bash

# Full path to the april data to process
FILES=/Users/ahume/FLIP/SensitivityAnalysis/data/processedWeather/lat_lon_2010_*.csv
FRAMEWORK_MODEL_DIR=/Users/ahume/FLIP/FrameworkModel

# Loop through all the data files
for f in $FILES
do
    echo $f

    airtFile=${f/lat_lon/airt}
    swradFile=${f/lat_lon/swrad}
    resultFile=${f/lat_lon/result}

    if [ -f $resultFile ]
    then
      echo "Skipping - already done."
    else
      # Read the lat/lon
      lat=`tail -1 $f | cut -d" " -f1`
      lon=`tail -1 $f | cut -d" " -f2`
      echo $lat
      echo $lon
      echo $airtFile
      echo $swradFile
    
      cp runMatlab-template.m runMatlab.m
      sed -e "s/LON/$lon/g" -i "" runMatlab.m
      sed -e "s/LAT/$lat/g" -i "" runMatlab.m
      sed -e "s+AIRT_FILE+$airtFile+g" -i "" runMatlab.m
      sed -e "s+SWRAD_FILE+$swradFile+g" -i "" runMatlab.m
      sed -e "s+RESULT_FILE+$resultFile+g" -i "" runMatlab.m
 
      mv runMatlab.m $FRAMEWORK_MODEL_DIR
      pushd $FRAMEWORK_MODEL_DIR
      /Applications/MATLAB_R2015b.app/bin/matlab -nodesktop -nosplash -r "runMatlab;exit"
      popd
    fi

done

