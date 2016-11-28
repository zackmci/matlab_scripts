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

filename='granular_flow_lube';
finaltime=7925;      % Last fluid timestep
a=csvread([filename,'.0.csv'],1,0);
ID=[5794 5748 4833 5177 5281 5079 5214 5455 5760 6171];
avg_part=[];
horizontal=[];
verticle=[];

ip=a(ID,8);

phi=atan(0.1);
theta=16*pi()/180;
K=2*sec(phi)^2*(1+(1-cos(phi)^2/cos(phi)^2)^(1/2))-1;

epsilon_cubed=32/(K*64)*(tan(phi)-tan(theta));
epsilon_squared=epsilon_cubed^2;

xinf=32*2/(1.155*epsilon_squared^(1/3));

% Sorting the files and pulling the values for particles in the gravity
% current.
for time=0:finaltime
    
    time
    
    a=csvread([filename,'.',num2str(time),'.csv'],1,0);
    
    a=sortrows(a,1);
 
        
    horizontal=cat(2,horizontal,a(ID,7));
    verticle=cat(2,verticle,a(ID,8));
    
        
end

% Plotting particle position
scatter(horizontal(1,:)/xinf,verticle(1,:)/ip(1));
hold on
scatter(horizontal(2,:)/xinf,verticle(2,:)/ip(2));
scatter(horizontal(3,:)/xinf,verticle(3,:)/ip(3));
scatter(horizontal(4,:)/xinf,verticle(4,:)/ip(4));
scatter(horizontal(5,:)/xinf,verticle(5,:)/ip(5));
scatter(horizontal(6,:)/xinf,verticle(6,:)/ip(6));
scatter(horizontal(7,:)/xinf,verticle(7,:)/ip(7));
scatter(horizontal(8,:)/xinf,verticle(8,:)/ip(8));
scatter(horizontal(9,:)/xinf,verticle(9,:)/ip(9));
scatter(horizontal(10,:)/xinf,verticle(10,:)/ip(10));

% Chart title and axes labels
title('Position of 10 particles in the gravity current');
xlabel('horizontal position/x_i_n_f');
set(gca, 'FontSize', 30);
ylabel('vertical position/h');
hold off

cd('/home/zack/Documents/matlab_scripts/')