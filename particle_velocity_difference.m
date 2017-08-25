%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% particle_velocity_difference
%
% inputs:
%   filename: name of the file to use for calculations
%       this file should be the saved vtp files from mfix
%   finaltime:  The timestep that the script looks at for the calculations
%   radius_of_search: This is the distance around the particle that the
%       script looks at to calculate the relative velocities.
%   x_dist: This is the portion along the x axis that is not to be
%       considered.  Isolating specific regimes
%   y_dist: This is the portion along the y axis that is not to be
%       considered.  Isolating specific regimes
%
% results
%   There are 4 plots that are a result of the script.  The first is a
%   histogram of the angles that the particles are moving towards each
%   other, the second is the abolute value of the angles,  The absolute
%   velocity of the particles is the third histogram, and the last plot is
%   the corrected vn and vt plotted in a scatter plot.
% med_mag_vel: is the median velocity of the magnitude of the relative
%   velocities.
% med_mag_part_vel: is the median value of the magnitude of the particle
%   velocities.
% 
% Author: Zack McIntire
% Date: 08/25/2017
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

% Initial inputs for run
filename='granular_flow_fric_7900';
%filename='granular_flow_lube';
finaltime=7900;
%finaltime=9999;
%number_of_particles=8127;
radius_of_search=0.6;
%x_vel=zeros(6,number_of_particles);
%y_vel=zeros(6,number_of_particles);
x_dist=42;
y_dist=0;

cd('/home/zack/Documents/csv_data_files/')

vtpdata=csvread([filename,'.',num2str(finaltime),'.csv'],1,0);

vtpdata(vtpdata(:,7)<=x_dist,:)=[];
vtpdata(vtpdata(:,8)<=y_dist,:)=[];

veldata=vtpdata(:,[4,5]);

vtpsize=size(vtpdata);
number_of_particles=vtpsize(1,1);

particle_number=linspace(1,number_of_particles,number_of_particles);
particle_number=transpose(particle_number);

vtpdata=cat(2,vtpdata,particle_number);

for particle=1:number_of_particles
    
    particle
    
    position_data=vtpdata;
    
    particle_data=position_data(position_data(:,10)==particle,:);
    
    % using only the particles within the specified distance from the 
    position_data(position_data(:,7)>particle_data(:,7)+...
        radius_of_search,:)=[];
    position_data(position_data(:,7)<particle_data(:,7)-...
        radius_of_search,:)=[];
    position_data(position_data(:,8)>particle_data(:,8)+...
        radius_of_search,:)=[];
    position_data(position_data(:,8)<particle_data(:,8)-...
        radius_of_search,:)=[];
    position_data(particle_data(:,1)==position_data(:,1),:)=[];
    
   % calculating the velocities
    x_vel=particle_data(:,4)-position_data(:,4);
    y_vel=particle_data(:,5)-position_data(:,5);
    
    % calculating the x and y distance from selected particle
    x_pos=particle_data(:,7)-position_data(:,7);
    y_pos=particle_data(:,8)-position_data(:,8);
    
    %this removes the particle from the vtpdata file so it is not double
    %counted from other particles.
    vtpdata(vtpdata(:,10)==particle,:)=[]; 
    
    % total distance
    dist=sqrt(x_pos.^2 + y_pos.^2);
    
    % positions normalized to total distance
    x_norm=x_pos./dist;
    y_norm=y_pos./dist;
    
    % calculating the normal velocity
    vn{particle}=x_norm.*x_vel-y_norm.*y_vel;
    
    % the perpendiculat distances normalized to total distance
    x_tan=y_pos./dist;
    y_tan=x_pos./dist;
    
    % calculating the tangential velocities
    vt{particle}=x_vel.*x_tan-y_vel.*y_tan;
    
    % magnitude of the normal and tangential velocities
    v_mag{particle}=sqrt(vt{particle}.^2+vn{particle}.^2);
end


vn2=[];
vt2=[];
for particle=1:number_of_particles
    vn2=[vn2;vn{particle}];
    vt2=[vt2;vt{particle}];
end

angle=atan(vn2./vt2)*180/pi;hist(angle)
med_mag_vel=median(sqrt(vn2.^2+vt2.^2));

hist(angle,50)

figure()
hist(abs(angle),50)
title('absolute value of the magnetude of vn and vt')

%vtpdata2=csvread([filename,'.',num2str(finaltime),'.csv'],1,0);
figure()
hist(sqrt(veldata(:,1).^2+veldata(:,2).^2),100)
title('magnitude of the particle velocity')
med_mag_part_vel=median(sqrt(veldata(:,1).^2+veldata(:,2).^2));

figure()
scatter(vn2, vt2)
xlabel('vn')
ylabel('vt')
% % plotting the normal velocity to the tangential velocity
% for particle=1:number_of_particles
%    
%     hold on
%     scatter(vn{particle}, vt{particle})
%     xlabel('vn')
%     ylabel('vt')
% 
% end

%figure
%plot(v_mag)

cd('/home/zack/Documents/matlab_scripts/')