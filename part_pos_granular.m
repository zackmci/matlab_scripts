%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% avg_velocity_granular
%
% Input csv data generated from res files using Paraview. This file 
%   calculates and plots the position of 10
%   particles from the granular flow for each timestep.
%
% July 26, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

cd('/home/zack/Documents/csv_data_files/')

filename='granular_flow_lube';
finaltime=7925;      % Last fluid timestep
a=csvread([filename,'.0.csv'],1,0);
ID=[6256 359 828 4928 1789 3184 1134 5669 2089 6410];
avg_part=[];
horizontal=[];
verticle=[];

ip=a(ID,8);

% Sorting the files and pulling the values for particles in the gravity
% current.
for time=0:finaltime
    
    time
    
    a=csvread([filename,'.',num2str(time),'.csv'],1,0);
    
    a=sortrows(a,1);
 
        
    horizontal=cat(2,horizontal,a(ID,7));
    verticle=cat(2,verticle,a(ID,8));
        
        
end

psi=(.36*.1+21.2)*pi()/180;
A=32*64;
BH=A*2;
B=sqrt(BH/tan(psi));

% Plotting particle position
scatter(horizontal(1,:)/B,verticle(1,:)/ip(1));
hold on
scatter(horizontal(2,:)/B,verticle(2,:)/ip(2));
scatter(horizontal(3,:)/B,verticle(3,:)/ip(3));
scatter(horizontal(4,:)/B,verticle(4,:)/ip(4));
scatter(horizontal(5,:)/B,verticle(5,:)/ip(5));
scatter(horizontal(6,:)/B,verticle(6,:)/ip(6));
scatter(horizontal(7,:)/B,verticle(7,:)/ip(7));
scatter(horizontal(8,:)/B,verticle(8,:)/ip(8));
scatter(horizontal(9,:)/B,verticle(9,:)/ip(9));
scatter(horizontal(10,:)/B,verticle(10,:)/ip(10));

% Chart title and axes labels
title('Position of 10 particles in the granular flow');
xlabel('horizontal position/l^*');
set(gca, 'FontSize', 30);
ylabel('vertical position/h');
hold off


      

cd('/home/zack/Documents/matlab_scripts/')