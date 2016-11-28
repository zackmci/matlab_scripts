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
%ID=[6256 359 828 4928 1789 3184 4230 5669 2089 6410];
avg_part=[];
% avg_height=[];

% % Sorting the files and pulling the values for highest particle and storing
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
    
    new_data=csvread([filename,'.',num2string(timestep),'.csv'],1,0);
    
    % ** UNCOMMENT ONLY IF LOOKING AT MIXING REGION PROBLEMS **
    vtpdatas=csvread([filename,'.',num2str(timestep),'.csv'],1,0);
    
    % Calculate the total mass of the system
    total_mass = sum((4/3)*pi()*(vtpdatas(:,2)/2).^3 .* vtpdatas(:,3));
    
    % Calculate the center of mass in the x direction
    x_mean = (sum((4/3)*pi()*(vtpdatas(:,2)/2).^3 .* vtpdatas(:,3).* ...
       vtpdatas(:,7)))/total_mass;
    % Calculate the center of mass in the y direction
    y_mean = (sum((4/3)*pi()*(vtpdatas(:,2)/2).^3 .* vtpdatas(:,3).* ...
        vtpdatas(:,8)))/total_mass;
    
    new_data(new_data(:,4) < x_mean-box_size,:)=[];
    new_data(new_data(:,6) < x_mean-box_size,:)=[];
    new_data(new_data(:,4) > x_mean+box_size,:)=[];
    new_data(new_data(:,6) > x_mean+box_size,:)=[];
    
    new_data(new_data(:,5) < y_mean-box_size,:)=[];
    new_data(new_data(:,7) < y_mean-box_size,:)=[];
    new_data(new_data(:,5) > y_mean+box_size,:)=[];
    new_data(new_data(:,7) > y_mean+box_size,:)=[];

    % avg_height=sortrows(avg_height,1);
    height=y_mean;
    diameter=mean(new_data(end,2));  % Diameter in cm.
    d=diameter/100;     % Diameter in meters
    density=mean(new_data(end,3))*1000;
    mass = mean(new_data(end,3))*4/3*pi*(diameter/2)^3;   % Mass in grams
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

    % % Setting the id value of the highest particle.
    % id=a(end,1);
    
    % % Creating an array of seconds normalized to the characteristic fall time.
    % for time=0:finaltime
    
    t=time/100;
    sec=cat(1,sec,t/tn);
    
    % end
    
    % Finding the kinetic energy from the model, and calculating the potential
    % energy for normalization.
    velocity=sqrt(mean(new_data(:,4)).^2+(mean(new_data(:,5)).^2));
    kin = mass*velocity.^2/2;
    energy=mass*g*height;

% Plotting velocity and kinetic energy over time.
[ax,p1,p2]=plotyy(sec, -new_data(:,5)/vn, sec, kin./energy);
set(ax, 'FontSize', 30);
set(gca,'box','off');
set(ax(1),'Ylim', [-1 6]);
set(ax(2),'Ylim', [-0.65*10e-6 4*10e-6]);
set(p1,'linewidth',2);
set(p2,'linewidth',2);
title('Average velocity of 10 particles from the heap flow');
xlabel((ax(1)),'t/(H/v_s)');
ylabel(ax(1),'velocity/v_s');
ylabel(ax(2),'KE/(mgH)');
hold on 
p3=plot(sec, avg_part(:,4)/vn, 'g-');
set(p3, 'linewidth', 2);
legend('vertical velocity','horizontal velocity','kinetic energy');
hold off

cd('/home/zack/Documents/matlab_scripts/')