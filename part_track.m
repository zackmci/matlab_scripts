%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% part_track_gravity
%
% Input csv data generated from vtp from Paraview
% 
% Inputs: 'filename', number of final timestep
%
% Outputs: creates a csv file that only has the 10 particles whose
%   Id's are entered.  These ids should be from the gravity current and 
%   allow tracking of the particles in paraview.
%
% August 26, 2016
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filename must be entered as a string, finaltime is final timestep

filename='granular_flow_lube';
finaltime=7925;
diameter=0.6;
id=[5794 5748 4833 5177 5281 5079 5214 5455 5760 6171];
part_trac=[];

cd('/home/zack/Documents/csv_data_files/')

% Read in initial timestep data to calculate locations
% Columns read in are: Id, Diameter, Density, U, V, W, X, Y, Z
vtpdata=csvread([filename,'.0.csv'],1,0);

% Sorts the output by Id (column 1)
sorted=sortrows(vtpdata,1);


% Headers to be used in file
headers={'Ids', 'Diameter', 'Position:0', 'Position:1', 'Position:2'};

% Loop to repeat this for all timesteps
for i=7297:finaltime,
    i 
    vtpdata=csvread([filename,'.',num2str(i),'.csv'],1,0);
    sorted=sortrows(vtpdata,1);
    part_trac=sorted(id,:);
    part_trac(:,6)=[];
    part_trac(:,5)=[];
    part_trac(:,4)=[];
    part_trac(:,3)=[];
    csvwrite_with_headers([filename,'_trc_grav.',num2str(i),'.csv'], ...
        part_trac, headers, 0, 0);
end

cd('/home/zack/Documents/matlab_scripts/')
