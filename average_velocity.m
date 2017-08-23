%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% avg_velocity
%
% Input csv data generated from res files using Paraview. This file 
%   calculates and plots the average vericle velocity of10
%   particles from the gravity current for each timestep.
%
% July 26, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

cd('/home/zack/Documents/csv_data_files/')

filename='granular_flow_fric_7900';
finaltime=7900;      % Last fluid timestep
a=csvread([filename,'.0.csv'],1,0);
ID=[4441 6110 4796 5047 4937 6407 4511 5569 5570 4383];
avg_part=[];
height=a(end,8);
avg_height=[];

% avg_height=sortrows(avg_height,1);
height=64;
diameter=mean(a(:,2));  % Diameter in cm.
d=diameter/100;     % Diameter in meters
density=mean(a(:,3))*1000;
mass = a(end,3)*4/3*pi*(diameter/2)^3;   % Mass in grams
g = 981;                 % Gravitational acceleration (cm/s2)
gravity=9.81; % Gravitational acceleration (m/s2)
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

% Sorting the files and pulling the values for highest particle and storing
% as a separate file.
for time=0:finaltime
    
    part_ten=[];
    
    time
    
    a=csvread([filename,'.',num2str(time),'.csv'],1,0);
    
    a=sortrows(a,1);
    for n=1:10
        
        part_ten=cat(1,part_ten,a(ID(n),:));
    
    end   
    
    avg_part=cat(1,avg_part,mean(part_ten));
    % avg_height=cat(1,avg_height,mean(part_ten(:,8)));

end    



% Setting the id value of the highest particle.
id=a(end,1);

% Creating an array of seconds normalized to the characteristic fall time.
for time=0:finaltime
    
    t=time/100;
    sec=cat(1,sec,t/tn);
    
end

% Finding the kinetic energy from the model, and calculating the potential
% energy for normalization.
velocity=sqrt(avg_part(:,4).^2+(avg_part(:,5).^2));
kin = mass*velocity.^2/2;
energy=mass*g*height;

% Plotting velocity and kinetic energy over time.
[ax,p1,p2]=plotyy(sec, -avg_part(:,5)/vn, sec, kin./energy);
set(ax, 'FontSize', 30);
set(gca,'box','off');
set(ax(1),'Ylim', [-5 20]);
set(ax(1),'xlim',[0 0.83]);
set(ax(2),'Ylim', [-0.28*10e-4 2.0*10e-4]);
set(ax(2),'xlim',[0 0.83]);
set(p1,'linewidth',2);
set(p2,'linewidth',2);
title('Average velocity of 10 particles in the gravity current (0.58)');
xlabel((ax(1)),'t/\tau');
ylabel(ax(1),'V/V*');
ylabel(ax(2),'KE/PE');
hold on 
p3=plot(sec, avg_part(:,4)/vn, 'g-');
set(p3, 'linewidth', 2);
legend('floor normal velocity','floor parallel velocity','kinetic energy');
hold off

cd('/home/zack/Documents/matlab_scripts/')