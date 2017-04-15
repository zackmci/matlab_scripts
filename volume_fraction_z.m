clear all;
close all;

% Initial inputs for run
filename='granular_flow_fric_7900';
filename2='granular_flow_fric_7900_fluid';
finaltime=7900;

% Initialize vectors to store centers of mass
centers_of_mass_x=zeros(1,finaltime);
centers_of_mass_y=zeros(1,finaltime);

cd('/home/zack/Documents/csv_data_files/')

% Headers to be used in file
headers={'phi', 'z'};
headers2={'t*', 'ave_phi'};

diameter = 0.6;

a=csvread([filename,'.0.csv'],1,0);height=64;
density=mean(a(:,3))*1000;
diameter=mean(a(:,2));  % Diameter in cm.
d=diameter/100;     % Diameter in meters
g = 981;                 % Gravitational acceleration (cm/s2)
gravity=9.81; % Gravitational acceleration (m/s2)
mu=1;      % viscosity of the fluid (Pascal seconds)
rol=2650;   % Density of the fluid
Ui = 1;     % Initial guess for velocity
Um = 0.5;   % Introducing the falling velocity term for a single 
                % particle.

% Calculating V* settling velocity for a single particle.
while (Um ~= Ui)
    Re = d*Ui*rol/mu;
    Ui = Um;
    Cd = 24/Re*(1+0.15*Re^(0.687))+0.42/(1+42500*Re^(-1.16));
    Um = (8*gravity*d/2*abs(density-rol)/(3*rol*Cd))^(1/2);
end

% The velocity and timescales for normalization purposes.
% Normalizing to a single particle velocity and the time it would take for
% the particle to fall the height of the column.
vn=Um*100;
tn=height/vn;

% Read in timesteps data to determine center of mass
% Columns read in are: Id, Diameter, Density, U, V, W, X, Y, Z
for timestep=0:finaltime
     
    cd('/home/zack/Documents/csv_data_files/')
    
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
    
    a=cat(2,diameter,x_mean);
    a=cat(2,a,y_mean);
    
    x_coord = round(x_mean);
    
    vfdata=csvread([filename2,'.',num2str(timestep),'.csv'],1,0);
    
    vfdata(vfdata(:,7) ~= x_coord, :) = [];
    vfdata(vfdata(:,1) == 1,:) = [];
    
    phi = [(1 - vfdata(:,1)) vfdata(:,8)];

    csvwrite_with_headers([filename2,'_volume_fraction.',...
        num2str(timestep),'.csv'],phi,headers,0,0);
    
    t=timestep/100;
    sec=t/tn;
    
    aphi_time = [(mean(vfdata(:,1))-1) sec];
end

csvwrite_with_headers([filename2,'_average_phi.csv'],aphi_time,headers2,...
    0,0);


cd('/home/zack/Documents/matlab_scripts/')
