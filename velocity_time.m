%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% velocity_time
%
% Input csv data generated from res files using Paraview. This file 
%   calculates and plots the average vericle velocity of the top 10
%   particles for each timestep.
%
% July 26, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('/home/zack/Documents/csv_data_files/')

filename='granular_flow_lube';
finaltime=4907;      % Last fluid timestep
a=csvread([filename,'.0.csv'],1,0);
a=sortrows(a,8);
diameter=a(end,2);  % Diameter in cm.
d=diameter/100;     % Diameter in meters
density=a(end,3)*1000;                        % Density in Kg/m3
height=a(end,8);
mass = a(end,3)*4/3*pi*(diameter/2)^3;   % Mass in grams
g = 981;                 % Gravitational acceleration (cm/s2)
gravity=9.81; % Gravitational acceleration (m/s2)
%tn = sqrt(diameter / g)*100;   % Normalization factor for time
%vn = sqrt(diameter * g);   % Normalization factor for velocity
vel_time=[];
sec=[];
mu=1;      % viscosity of the fluid (Pascal seconds)
rol=2650;   % Density of the fluid
Ui = 1;     % Initial guess for velocity
Um = 0.5;   % Introducing the falling velocity term for a single particle.


% Calculating V* settling velocity for a single particle.
while (Um ~= Ui)
    Re = d*Ui*rol/mu;
    Ui = Um;
    Cd = 24/Re*(1+0.15*Re^(0.687))+0.42/(1+42500*Re^(-1.16));
    Um = (8*gravity*d/2*abs(density-rol)/(3*rol*Cd))^(1/2);
end

% The velocity and timescales for normalization purposes.
% NOrmalizing too a single particle velocity and the time it would take for
% the particle to fall the height of the column.
vn=Um*100;
tn=height/vn;

% Setting the id value of the highest particle.
id=a(end,1);

% Sorting the files and pulling the values for highest particle and storing
% as a separate file.
for time=0:finaltime
    
    time
    
    a=csvread([filename,'.',num2str(time),'.csv'],1,0);
    
    a=sortrows(a,1);
    
    vel_time=cat(1,vel_time,a(2693,:));
    
end    
                                    


% Averaging verticle velocities for highest 10 particles


% Creating an array of seconds normalized to the characteristic fall time.
for time=0:finaltime
    
    t=time/100;
    sec=cat(1,sec,t/tn);
    
end

% Finding the kinetic energy from the model, and calculating the potential
% energy for normalization.
velocity=sqrt(vel_time(:,4).^2+(vel_time(:,5).^2));
kin = mass*velocity.^2/2;
energy=mass*g*height;

% Plotting velocity and kinetic energy over time.
[ax,p1,p2]=plotyy(sec, -vel_time(:,5)/vn, sec, kin./energy);
set(gca,'box','off');
set(ax(1),'Ylim', [-0.5 5]);
set(ax(2),'Ylim', [0 4*10e-6]);
set(p1,'linewidth',2);
set(p2,'linewidth',2);
title('Velocity over time for highest particle');
xlabel((ax(1)),'t/(height/V*)');
ylabel(ax(1),'velocity/V*');
ylabel(ax(2),'kinetic energy/(mgh)');
hold on 
p3=plot(sec, vel_time(:,4)/vn, 'g-');
set(p3, 'linewidth', 2);
legend('vertical velocity','horizontal velocity','kinetic energy');
hold off

cd('/home/zack/Documents/matlab_scripts/')

