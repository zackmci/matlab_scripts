%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Color_bands
%
% Input csv data generated from vtp from Paraview
% 
% Inputs: 'filename', number of final timestep
%
% Outputs: creates a csv file with the particles sorted by their id and
%   has a location associated with it (file name has 'loc' before the 
%   number)
%
% September 3, 2015
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% filename must be entered as a string, finaltime is final timestep

filename='gravity_flow_fc1';
finaltime=5996;
diameter=0.6;

cd('/home/zack/Documents/csv_data_files/')

% Read in initial timestep data to calculate locations
% Columns read in are: Id, Diameter, Density, U, V, W, X, Y, Z
vtpdata=csvread([filename,'.0.csv'],1,0);

% Sorts the output by Id (column 1)
sorted=sortrows(vtpdata,1);

% Bed Heights~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Calculates the height of the bed, using the top 1% of particles

% Sorts particles by their height and picks the top 1%
heights=sortrows(vtpdata,8);
calc_one=length(heights)-floor(length(heights)*0.01);
one_percent=heights(calc_one:end,:);

% Gets the average height of the center of the particles
ave=mean(one_percent);
yave=ave(8)+diameter/2;       % prints out initial bed height
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

location=sorted(:,8)/yave;

% Calculates 1 or 0 for top or bottom half of particle domain
%location=floor(sorted(:,8)/(max(sorted(:,8)+0.01)/2));

% Adds location to rest of particle information
newfile=cat(2,sorted,location);

% Headers to be used in file
headers={'Ids', 'Diameter', 'Density','Velocity:0', 'Velocity:1', ... 
    'Velocity:2', 'Position:0', 'Position:1', 'Position:2', 'Location'};

% Writes the first timestep including the locations and headers
csvwrite_with_headers([filename,'_loc.0.csv'], newfile, headers, 0, 0);

% Loop to repeat this for all timesteps
for i=1:finaltime,
    i 
    vtpdata=csvread([filename,'.',num2str(i),'.csv'],1,0);
    sorted=sortrows(vtpdata,1);
    newfile=cat(2,sorted,location);
    csvwrite_with_headers([filename,'_loc.',num2str(i),'.csv'],newfile, ...
        headers, 0, 0);
end

cd('/home/zack/Documents/matlab_scripts/')


