temp  = csvread('AIRT_FILE',1,0);
swrad = csvread('SWRAD_FILE',1,0);
lat = LAT;
lon  = LON;
result_file = 'RESULT_FILE';

fileId = fopen(result_file,'w');

% hour is repeats of 1..24
hour = 0:(24*365);
hour = mod(hour,24)+1;

sunrise = zeros(24*365,1);
sunset  = zeros(24*365,1);
co2     = zeros(24*365,1)+42;

day = 100;  % the day to start the simulation, 10 April

% Complete sunrise and sunset data
for d = 1:365
    rise = 0;
    set = 0;
    
    for i = (((d-1)*24)+1):(d*24)
        if (swrad(i) > 0) 
            if (rise == 0) 
                rise = hour(i);
            end
            set = hour(i);
        end
    end
    
    for i = (((d-1)*24)+1):(((d)*24))
        sunrise(i) = rise-0.5;
        sunset(i)  = set+0.5;
    end
    
end

% Now longer starting during day as the whole code is designed to offset sunrise and sunset from a day starting a hour 1
startIndex = (day-1)*24+1;

% The old code commented out in case we need it again
% Find first hour of the simulation - first light on the given day
%startIndex = 1;
%for i = (day*24):length(swrad)
%
%    if swrad(i) > 0 
%        startIndex = i;
%        break
%    end
%end


% Need to calculate the photoperiod - going to average over the 30
% day period from the start.  30 days being an approximation on how
% long it takes a plant to grow.  We need this because the FM currently
% uses a fixed photoperiod over the whole simulation.
% Count how many hours of non-zero PAR we have over 30 days and average it
sunnyHours = 0;
numberOfDaysInSample = 30;
for i = (day*24):((day+numberOfDaysInSample)*24)
   if swrad(i) > 0
       sunnyHours = sunnyHours + 1;
   end    
end
averagePhotoperiod = sunnyHours/numberOfDaysInSample;

% Adjust the data to our starting time of year
hour    = hour(startIndex:end);
temp    = temp(startIndex:end);
swrad   = swrad(startIndex:end);
sunrise = sunrise(startIndex:end);
sunset  = sunset(startIndex:end);
co2     = co2(startIndex:end);

% Ready to run the simulation now

%Specifying the genotype for the clock and starch models
experiment_genotype_index = 1;
switch experiment_genotype_index
    case 1
        w = 0.91; %water content
        mf_use = 0.7; %malate+fumarate turnover
    case 2
        w = 0.89; %water content
        mf_use = 0.7; %malate+fumarate turnover
    case 3
        w = 0.89; %water content
        mf_use = 0.7; %malate+fumarate turnover
    case 4
        w = 0.89; %water content
        mf_use = 0.25; %malate+fumarate turnover
end

% w = 0.9;
d = 1-w; %dry matter

load('parameter.mat');

p=parameter;
p0 = p;

clock_genotype = {''};
% clock_genotype = {'prr9','prr7'};
starch_genotype = {''};
clock_parameters0 = P2011_parameter_call(clock_genotype);
clock_parameters = clock_parameters0;
nCP = length(clock_parameters);

starch_parameters0 = starch_parameter_call(starch_genotype);
starch_parameters = starch_parameters0;

run_phenology_model = 1;


% Need to do the basal run this will have parameter 0

try
      detailsFile = fopen(strcat(result_file,int2str(0)),'w');
[sim_data,~] = simulate_FM_ach(hour,temp,sunrise,sunset,co2,swrad,averagePhotoperiod,clock_parameters,starch_parameters,p0,d,mf_use,run_phenology_model,detailsFile);
   flose(detailsFile);
catch ME
sim_data = [-1,-1,-1,-1];
end
fprintf(fileId, '%d,%f,%f,%f,%f,%f,%f\n',0,lat,lon,sim_data(1),sim_data(2),sim_data(3),sim_data(4));

% Now need to loop though the main parameters
deltaP = 0.01;
nP = length(p);

% for i = 1:nP
%     i
%     p = p0;
%     p(i) = p(i)*(1+deltaP);
%     try
%       detailsFile = fopen(strcat(result_file,int2str(i)),'w');
%       [sim_data,~] = simulate_FM_ach(hour,temp,sunrise,sunset,co2,swrad,averagePhotoperiod,clock_parameters,starch_parameters,p,d,mf_use,run_phenology_model,detailsFile);
%       fclose(detailsFile);
%     catch ME
%       sim_data = [-1,-1,-1,-1];
%     end
%     fprintf(fileId, '%d,%f,%f,%f,%f,%f,%f\n',i,lat,lon,sim_data(1),sim_data(2),sim_data(3),sim_data(4));
% end


% p = p0;
% for i = nP+1:nP+nCP
%     i
%     clock_parameters = clock_parameters0;
%     clock_parameters(i-nP) = clock_parameters(i-nP)*(1+deltaP);
%     try
%       detailsFile = fopen(strcat(result_file,int2str(i)),'w');
%       [sim_data,~] = simulate_FM_ach(hour,temp,sunrise,sunset,co2,swrad,averagePhotoperiod,clock_parameters,starch_parameters,p,d,mf_use,run_phenology_model,detailsFile);
%       fclose(detailsFile);
%     catch ME
%       sim_data = [-1,-1,-1,-1];
%     end
%     fprintf(fileId, '%d,%f,%f,%f,%f,%f,%f\n',i,lat,lon,sim_data(1),sim_data(2),sim_data(3),sim_data(4));
% end

% Number of starch parameters
%nSP = 15;
%clock_parameters = clock_parameters0;
%for i = nP+nCP+1:nP+nCP+nSP
%    i
%    starch_parameters = starch_parameters0;
%    switch i-nP-nCP
%        case 1
%            starch_parameters.ksY = starch_parameters.ksY*(1+deltaP);
%        case 2
%            starch_parameters.kdY = starch_parameters.kdY*(1+deltaP);
%        case 3
%            starch_parameters.ksS = starch_parameters.ksS*(1+deltaP);
%        case 4
%            starch_parameters.KsS = starch_parameters.KsS*(1+deltaP);
%        case 5
%            starch_parameters.kdS = starch_parameters.kdS*(1+deltaP);
%        case 6
%            starch_parameters.KdS = starch_parameters.KdS*(1+deltaP);
%        case 7
%            starch_parameters.KdSX = starch_parameters.KdSX*(1+deltaP);
%        case 8
%            starch_parameters.ksX = starch_parameters.ksX*(1+deltaP);
%        case 9
%            starch_parameters.kdX= starch_parameters.kdX*(1+deltaP);
%        case 10
%            starch_parameters.ksT1= starch_parameters.ksT1*(1+deltaP);
%        case 11
%            starch_parameters.ksT2= starch_parameters.ksT2*(1+deltaP);
%        case 12
%            starch_parameters.KsT2= starch_parameters.KsT2*(1+deltaP);
%        case 13
%            starch_parameters.kdT1= starch_parameters.kdT1*(1+deltaP);
%        case 14
%            starch_parameters.kdT2= starch_parameters.kdT2*(1+deltaP);
%        case 15
%            starch_parameters.KdT2= starch_parameters.KdT2*(1+deltaP);
%    end
%    try
%      detailsFile = fopen(strcat(result_file,int2str(i)),'w');
%      [sim_data,~] = simulate_FM_ach(hour,temp,sunrise,sunset,co2,swrad,averagePhotoperiod,clock_parameters,starch_parameters,p,d,mf_use,run_phenology_model,detailsFile);
%      fclose(detailsFile);
%    catch ME
%      sim_data = [-1,-1,-1,-1];
%    end
%    fprintf(fileId, '%d,%f,%f,%f,%f,%f,%f\n',i,lat,lon,sim_data(1),sim_data(2),sim_data(3),sim_data(4));
%        
%end

fclose(fileId);

