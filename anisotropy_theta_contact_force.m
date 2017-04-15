clear all; close all;

% ** Make sure to change below if looking at a mixing region problem **
filename='granular_flow_lube_fc';
filename2='granular_flow_lube';
finaltime=9999;
time_factor=0.01;
angle_bins=20;      % Number of bins for the circle
bin_angles=(2*pi)/angle_bins;

cd('/home/zack/Documents/csv_data_files/')

% Setting up arrays to hold a and theta values and the orientations
contact_a=[];
contact_theta=[];
fn_a=[];
fn_theta=[];
ft_a=[];
ft_theta=[];
binning_contacts=[];
binning_forces_n=[];
binning_forces_t=[];
% Reading in the data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd('/home/zack/Documents/csv_data_files/results/')
list1=csvread(['As_and_thetas_',filename,'_',num2str(angle_bins), ...
    'bins.csv'],0,0);
list2=csvread(['Orientations_',filename,'_',num2str(angle_bins), ... 
    'bins.csv'],0,0);

contact_a=list1(:,1);
contact_theta=list1(:,2);
fn_a=list1(:,3);
fn_theta=list1(:,4);
ft_a=list1(:,5);
ft_theta=list1(:,6);
binning_contacts=list2(:,1:finaltime);
binning_forces_n=list2(:,finaltime+1:2*finaltime);
binning_forces_t=list2(:,2*finaltime+1:end);

cd('/home/zack/Documents/csv_data_files/')

ave_coord=csvread(['ave_coord_',filename,'.csv'],0,0);

a=csvread([filename2,'.0.csv'],1,0);
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

while (Um ~= Ui)
    Re = d*Ui*rol/mu;
    Ui = Um;
    Cd = 24/Re*(1+0.15*Re^(0.687))+0.42/(1+42500*Re^(-1.16));
    Um = (8*gravity*d/2*abs(density-rol)/(3*rol*Cd))^(1/2);
end

vn=Um*100;
tn=height/vn;

for timestep=1:finaltime
    t=timestep/100;
    sec=cat(1,sec,t/tn);
end

[ax,p1,p2]=plotyy(sec, contact_a, sec, ave_coord);
set(ax, 'FontSize', 30);
set(gca,'box','off');
set(ax(1),'Ylim', [0 0.6]);
set(ax(1),'xlim', [0 1.053]); % For 0.58 friction
% set(ax(1),'xlim', [0 1.053]); % For 0.1 friction
set(ax(2),'Ylim', [2.8 3.8]);
set(ax(2),'xlim', [0 1.053]); % For 0.58 friction
% set(ax(2),'xlim', [0 1.053]); % For 0.1 friction
xlabel((ax(1)),'t*');
ylabel(ax(1),'a_C');
ylabel(ax(2),'Z');
hold on 
p3=plot([0.11 0.11],[0 0.6],'g-');


cd('/home/zack/Documents/matlab_scripts/')