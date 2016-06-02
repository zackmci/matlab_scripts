%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Center of Mass
%
% Input csv data generated from vtp files using Paraview. This file 
%   calculates the center of mass for particles with any density and 
%   diameter
%
% Inputs: 'filename', number of final timestep
%
% Outputs: creates a figure tracking the center of mass, and a text file 
%   of the value of the center of mass for all time steps. 
%
% June 2, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial inputs for run
filename='gravity_flow_fc1';
finaltime=5996;

% Initialize vectors to store centers of mass
centers_of_mass_x=zeros(1,finaltime);
centers_of_mass_y=zeros(1,finaltime);

cd('/home/zack/Documents/csv_data_files/')


% Read in timesteps data to determine center of mass
% Columns read in are: Id, Diameter, Density, U, V, W, X, Y, Z
for timestep=0:finaltime
    
    timestep
    
    vtpdata=csvread([filename,'.',num2str(timestep),'.csv'],1,0);

    % Calculate the total mass of the system
    total_mass = sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3));
    
    % Calculate the center of mass in the x direction
    x_mean = (sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3).* ...
        vtpdata(:,7)))/total_mass;
    % Calculate the center of mass in the y direction
    y_mean = (sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3).* ...
        vtpdata(:,8)))/total_mass;

    % Append the centers of mass to a vector
    centers_of_mass_x(timestep+1)=x_mean;
    centers_of_mass_y(timestep+1)=y_mean;
    
end


a=cat(1,centers_of_mass_x,centers_of_mass_y);
cd('/home/zack/Documents/csv_data_files/results/')
csvwrite(['Center_of_mass_',filename,'.csv'],a);

% Create a plot showing the center of mass through time
scatter(centers_of_mass_x,centers_of_mass_y)



cd('/home/zack/Documents/matlab_scripts/')
