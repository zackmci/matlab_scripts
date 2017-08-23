%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% avg_velocity_granular
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

filename='granular_flow_lube';
finaltime=9999;      % Last fluid timestep
a=csvread([filename,'.0.csv'],1,0);
box_size=5;
height=64;
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
%ID=[6256 359 828 4928 1789 3184 4230 5669 2089 6410];
% avg_part=[];
% avg_height=[];
energy_save=[];
v_velocity=[];
h_velocity=[];
sec=[];

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

% % Sorting the files and pulling the values for highest particle and 
% % storing
% % as a separate file.
% for time=0:finaltime
%     
%     part_ten=[];
%     
%     time
%     
%     a=csvread([filename,'.',num2str(time),'.csv'],1,0);
%     
%     a=sortrows(a,1);
%     for n=1:10
%         
%         part_ten=cat(1,part_ten,a(ID(n),:));
%     
%     end   
%     
%     avg_part=cat(1,avg_part,mean(part_ten));
%     % avg_height=cat(1,avg_height,mean(part_ten(:,8)));
% end  

for timestep=0:finaltime;
    
    timestep
    
    new_data=csvread([filename,'.',num2str(timestep),'.csv'],1,0);
    
    % Calculate the total mass of the system
    total_mass = sum((4/3)*pi()*(new_data(:,2)/2).^3 .* new_data(:,3));
    ave_mass = mean((4/3)*pi()*(new_data(:,2)/2).^3 .* new_data(:,3));
    
    % Calculate the center of mass in the x direction
    x_mean = (sum((4/3)*pi()*(new_data(:,2)/2).^3 .* new_data(:,3).* ...
       new_data(:,7)))/total_mass;
    % Calculate the center of mass in the y direction
    y_mean = (sum((4/3)*pi()*(new_data(:,2)/2).^3 .* new_data(:,3).* ...
        new_data(:,8)))/total_mass;
    
    new_data(new_data(:,7) < x_mean-box_size,:)=[];
    new_data(new_data(:,7) < x_mean+box_size,:)=[];
    
    new_data(new_data(:,8) < y_mean-box_size,:)=[];
    new_data(new_data(:,8) < y_mean+box_size,:)=[];
    mass = mean(new_data(:,3))*4/3*pi*(mean(new_data(:,2))/2)^3;   % Mass in grams
    

    
    % Calculating actual time from the timestep and then creating a vector
    % of that time scaled to the characteristic time of a single particle
    % settling the height of the column.
    
    t=timestep/100;
    sec=cat(1,sec,t/tn);
    
    % Finding the kinetic energy from the model, and calculating the 
    % potential
    % energy for normalization.
    velocity=sqrt(mean(new_data(:,4))^2+(mean(new_data(:,5)).^2));
    kin = mass*velocity^2/2;
    energy=kin/(ave_mass*g*height);
    energy_save=cat(1,energy_save,energy);
    
    vert_veloc=mean(new_data(:,5))/vn;
    hor_veloc=mean(new_data(:,4))/vn;
    v_velocity=cat(1,v_velocity,vert_veloc);
    h_velocity=cat(1,h_velocity,hor_veloc);
    
end
    

% Plotting velocity and kinetic energy over time.
[ax,p1,p2]=plotyy(sec, -v_velocity, sec, energy_save);
set(ax, 'FontSize', 30);
set(gca,'box','off');
set(ax(1),'Ylim', [-1 12]);
set(ax(1),'xlim', [0 0.83]);
set(ax(2),'Ylim', [-0.65*10e-5 8*10e-5]);
set(ax(2),'xlim', [0 0.83]);
set(p1,'linewidth',2);
set(p2,'linewidth',2);
title('Average velocity of particles around center of mass (0.58)');
xlabel((ax(1)),'t/\tau');
ylabel(ax(1),'V/V*');
ylabel(ax(2),'KE/PE');
hold on
p3=plot(sec, h_velocity, 'g-');
set(p3, 'linewidth', 2);
legend('floor normal velocity','floor parallel velocity','kinetic energy')
hold off


