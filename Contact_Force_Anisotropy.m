%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Contact & Force Anisotropy

%
% Reads csv file generated by Paraview of force chain data. The cohesive
%   force should not be included in these files.
%
% Inputs: 'filename', number of final timestep for force chains, time 
%   factor (how much time does one timestep represent)
%
% Outputs: creates a csv file of the contact and forces anisotropy value 
%   and theta value through time.
%
% Note: this has an option for only choosing particles within the mixing
%   region. The values must be entered manually and are not calculated in 
%   by the code.
%
% October 14, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

% ** Make sure to change below if looking at a mixing region problem **
filename='box256_9.3_everything_fc';
%filename='zack_ramp_fc';
%filename='box512_ht_1_fc';
%filename='box512_ht_fc';
%finaltime=1120;
finaltime=800;
%finaltime=50;
time_factor=0.125;
angle_bins=20;      % Number of bins for the circle
bin_angles=(2*pi)/angle_bins;

cd('/home/jmschl/Desktop/MixingCalculations/csvData/')

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

% Loop for timesteps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for timestep=1:finaltime,
    
    timestep
    
    % Read in and prep the data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    force_data=csvread([filename,'.',num2str(timestep),'.csv'],1,0);
    % Columns read in are: f_normal f_tangential f_magnitude x y z
    % There are 2 rows per contact
    
    force_data(:,6)=[];     % Remove z data
    
    points1=force_data(1:2:end,:);  % Just the first point in contacts
    points2=force_data(2:2:end,:);  % Just the second point in contacts
    
    all_contacts=cat(2,points1,points2(:,4:5));
    % Now columns are: f_n f_t f_m x1 y1 x2 y2
    
    % Removing duplicates: (x1,y1;x2,y2)=(x1,y1;x2,y2)
    all_contacts=unique(all_contacts,'rows','stable');

    % Removing reversed duplicates (x1,y1;x2,y2)=(x2,y2;x1,y1)
    reverse=all_contacts(:,1:3);                    % Copies force data
    reverse=cat(2,reverse,all_contacts(:,6:7));     % Copies X2 Y2
    reverse=cat(2,reverse,all_contacts(:,4:5));     % Copies X1 Y1
    % reverse columns are: f_n f_t f_m x2 y2 x1 y2
    
    % Getting a list of the reversed duplicates
    matching=intersect(all_contacts,reverse,'rows');
    pick_one=matching(1:2:end,:);       % Takes only 1 of the pairs
    
    % Finds the reversed duplicates and removes both rows for each pair
    [yes_no, index]=ismember(all_contacts,reverse,'rows');
    tested=cat(2,all_contacts,yes_no);
    tested(tested(:,8)==1,:)=[];
    tested(:,8)=[];
    
    % Add the reduced list to the list with 1 duplicate from each pair
    new_data=cat(1,pick_one,tested);
    % New columns: f_n f_t f_m x1 y1 x2 y2
    
    % ** UNCOMMENT ONLY IF LOOKING AT MIXING REGION PROBLEMS **
    new_data(new_data(:,4) < 64.5,:)=[];
    new_data(new_data(:,6) < 64.5,:)=[];
    new_data(new_data(:,4) > 191.5,:)=[];
    new_data(new_data(:,6) > 191.5,:)=[];
    
    % Calculate the orientations of the contacts, using mod to have the 
    %  data go from 0 to 2pi, instead of -pi to pi
    angles=mod(atan2(new_data(:,7)-new_data(:,5), ...
        new_data(:,6)-new_data(:,4)),2*pi);
    
    % Make it so all orientations are in the top half of the rose diagram
    forces_angles=cat(2,new_data(:,1:3),angles);
    low_angles=forces_angles(forces_angles(:,4)>pi,:);
    high_angles=forces_angles(forces_angles(:,4)<=pi,:);
    low_to_high=low_angles(:,4)-pi;
    low_angles(:,4)=low_to_high;
    all_high=cat(1,high_angles,low_angles);
    
    % Randomly choose half of the orientations and put them in the 
    %  bottom half of the rose diagram
    random_values=rand(length(all_high),1);
    all_high=cat(2,all_high,random_values);
    new_high_angles=all_high(all_high(:,5)<0.5,:);
    new_low_angles=all_high(all_high(:,5)>=0.5,:);
    new_low_angles(:,4)=new_low_angles(:,4)+pi;
    
    final_contacts=cat(1,new_high_angles,new_low_angles);
    % New columns: f_n f_t f_m angle random_number
    
    forces_n=final_contacts(:,1);
    forces_t=final_contacts(:,2);
    
%     % Sample data to test
    %orientations=[233,67,287,287,53,270,315,199,358]'*pi/180;
    %forces_n=[4, 6, 7, 4, 4, 7, 1, 2,3]';
%     orientations=[233,67,287,287,53,270,315,199]'*pi/180;
%     forces_n=[4, 6, 7, 4, 4, 7, 1, 2]';
    
    % Pull out orientations so I don't need to redo code
    orientations=final_contacts(:,4);

    force_n_mean=mean(forces_n);
    force_t_mean=mean(forces_t);   
    counts=length(orientations);
    
    % Contact calculations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Create the 2nd order fabric tensor
    f11c=cos(orientations).*cos(orientations);
    F11c=sum(f11c);
    f12c=cos(orientations).*sin(orientations);
    F12c=sum(f12c);
    F21c=F12c;
    f22c=sin(orientations).*sin(orientations);
    F22c=sum(f22c);
    
    Fij_c=(1/counts).*[F11c,F12c; F21c,F22c];
    
    % Calculate the eigenvalues and eigenvectors
    [e_vectors_c,e_values_c]=eig(Fij_c);
    
    % Calculate the orientations of the eigenvectors (from 0 to 2pi)
    thetas_c=mod(atan2(e_vectors_c(:,2),e_vectors_c(:,1)),2*pi);
    
    % Calculate the anisotropy 
    e_values_c=max(e_values_c);     % Removes extra 0s in the matrix
    a_value_c=(2*abs(e_values_c(1)-e_values_c(2)))/ ...
        (e_values_c(1)+e_values_c(2));
    % Find the anisotropy orientation
    [Mc,Ic]=max(e_values_c);
    theta_value_c=thetas_c(Ic);
    
    % Keep the number of contacts within each angle bin for plotting later
    [tout, rout]=rose(orientations,angle_bins);
    rout=reshape(rout,[4,angle_bins]);
    rout(1:2,:)=[];
    rout(2,:)=[];   
    
    % Add calculated a and theta to list through time, and number of binned
    %  contacts
    contact_a=cat(2,contact_a,a_value_c);
    contact_theta=cat(2,contact_theta,theta_value_c);
    binning_contacts=cat(2,binning_contacts,rout');
    
    % Normal Force calculations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Create the 2nd order fabric tensor
    f11n=forces_n.*cos(orientations).*cos(orientations);
    F11n=sum(f11n);
    f12n=forces_n.*cos(orientations).*sin(orientations);
    F12n=sum(f12n);
    F21n=F12n;
    f22n=forces_n.*sin(orientations).*sin(orientations);
    F22n=sum(f22n);
    
    Fij_n=(1/force_n_mean*counts).*[F11n,F12n; F21n,F22n];
    
    % Calculate the eigenvalues and eigenvectors
    [e_vectors_n,e_values_n]=eig(Fij_n);
    
    % Calculate the orientations of the eigenvectors (0 to 2pi)
    thetas_n=mod(atan2(e_vectors_n(:,2),e_vectors_n(:,1)),2*pi);
    
    % Calculate the anisotropy 
    e_values_n=max(e_values_n);     % Removes extra 0s from matrix
    a_value_n=(2*abs(e_values_n(1)-e_values_n(2)))/ ...
        (e_values_n(1)+e_values_n(2));
    % Find the anisotropy orientation
    [M_n,I_n]=max(e_values_n);
    theta_value_n=thetas_n(I_n);
    
    % Normal force diagram for current timestep - more involved than
    %  contacts because not just counting the number in each bin, but need 
    %  to find the average force of the contacts within each bin
    [N,edges,bin]=histcounts(orientations,0:2*pi/angle_bins:2*pi);

    % Calculate the mean force in each orientation bin
    bin_forces_n=cat(2,bin,forces_n);
    binned_forces_n=accumarray(bin_forces_n(:,1),bin_forces_n(:,2), ...
        [],@mean);
    binned_forces_n=padarray(binned_forces_n,[(length(N)- ...
        length(binned_forces_n)),0],'post');
    
    % Add calculated a and theta to list through time, and binned average
    %  normal forces
    fn_a=cat(2,fn_a,a_value_n);
    fn_theta=cat(2,fn_theta,theta_value_n);
    binning_forces_n=cat(2,binning_forces_n,binned_forces_n);
    
    % Tangential Force calculations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Create the 2nd order fabric tensor
    f11t=forces_t.*cos(orientations).*cos(orientations);
    F11t=sum(f11t);
    f12t=forces_t.*cos(orientations).*sin(orientations);
    F12t=sum(f12t);
    F21t=F12t;
    f22t=forces_t.*sin(orientations).*sin(orientations);
    F22t=sum(f22t);
    
    Fij_t=(1/force_t_mean*counts).*[F11t,F12t; F21t,F22t];
    
    % Calculate the eigenvalues and eigenvectors
    [e_vectors_t,e_values_t]=eig(Fij_t);
    
    % Calculate the orientations of the forces
    thetas_t=mod(atan2(e_vectors_t(:,2),e_vectors_t(:,1)),2*pi);
    % Calculate the anisotropy
    e_values_t=max(e_values_t);
    a_value_t=(2*abs(e_values_t(1)-e_values_t(2)))/ ...
        (e_values_t(1)+e_values_t(2));
    % Find the anisotropy orientation
    [M_t,I_t]=max(e_values_t);
    theta_value_t=thetas_t(I_t);
    
    % Calculate the mean tangential force within the orientation bins
    [N,edges,bin]=histcounts(orientations,0:2*pi/angle_bins:2*pi);
    bin_forces_t=cat(2,bin,forces_t);
    binned_forces_t=accumarray(bin_forces_t(:,1),bin_forces_t(:,2), ...
        [],@mean);
    binned_forces_t=padarray(binned_forces_t,[(length(N)- ...
        length(binned_forces_t)),0],'post');
    
       
    % Add calculated a and theta to list through time
    ft_a=cat(2,ft_a,a_value_t);
    ft_theta=cat(2,ft_theta,theta_value_t);
    binning_forces_t=cat(2,binning_forces_t,binned_forces_t);
    
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Saving the data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

saving_data=[contact_a', contact_theta',fn_a',fn_theta',ft_a',ft_theta'];
rose_diagram_data=[binning_contacts,binning_forces_n,binning_forces_t];

cd('/home/jmschl/Desktop/MixingCalculations')
csvwrite(['As_and_thetas_',filename,'_',num2str(angle_bins),'bins.csv'] ...
    ,saving_data,0,0);
csvwrite(['Orientations_',filename,'_',num2str(angle_bins),'bins.csv'], ...
    rose_diagram_data,0,0);
cd('/home/jmschl/Desktop/MixingCalculations/csvData/')

% Below is for already calculated lists %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Reading in the data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd('/home/jmschl/Desktop/MixingCalculations')
list1=csvread(['As_and_thetas_',filename,'_',num2str(angle_bins), ...
    'bins.csv'],0,0);
list2=csvread(['Orientations_',filename,'_',num2str(angle_bins), ... 
    'bins.csv'],0,0);
%cd('/home/jmschl/Desktop/MixingCalculations/csvData/')

contact_a=list1(:,1);
contact_theta=list1(:,2);
fn_a=list1(:,3);
fn_theta=list1(:,4);
ft_a=list1(:,5);
ft_theta=list1(:,6);
binning_contacts=list2(:,1:finaltime);
binning_forces_n=list2(:,finaltime+1:2*finaltime);
binning_forces_t=list2(:,2*finaltime+1:end);


% Plotting the temporal data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
t=0:length(contact_theta)-1; 
t=t/8;
% Plot thetas in radians through time
plot(t,contact_theta,t,fn_theta,t,ft_theta,'LineWidth',2)
legend('contact','normal force','tangential force')
xlim([0 finaltime/8])
xlabel('Time (s)')
ylabel('Theta (radians)')

% Plot thetas in degrees through time
plot(t,contact_theta*(180/pi),t,fn_theta*(180/pi),t,ft_theta*(180/pi), ...
    'LineWidth',2)
legend('contact','normal force','tangential force')
xlim([0 finaltime/8])
xlabel('Time (s)')
ylabel('Theta (degrees)')

% Plot aniosotropy value through time
plot(t,contact_a,t,fn_a,t,ft_a,'LineWidth',2)
legend('contact','normal force','tangential force')
xlim([0 100])
xlabel('Time (s)')
ylabel('Anisotropy')

% Plot rose diagrams for contacts and calculated anisotropy ~~~~~~~~~~~~~~~ 
toi=1100;      % Timestep of interest (looking at just 1 timestep)

[tout, rout]=rose(binning_contacts(:,toi),angle_bins);
new_rout_contacts=zeros(angle_bins,1);
new_rout_contacts=cat(2,new_rout_contacts,binning_contacts(:,toi));
new_rout_contacts=cat(2,new_rout_contacts,binning_contacts(:,toi));
new_rout_contacts=cat(2,new_rout_contacts,zeros(angle_bins,1));
new_rout_contacts=reshape(new_rout_contacts',[1,angle_bins*4]);

counts=sum(binning_contacts(:,toi));

theta=0:0.01:2*pi;

% Make invisible plot to adjust the maximum radius needed by the data
figure
radius=0.3;
P = polar(theta, radius * ones(size(theta)));
set(P, 'Visible', 'off')
hold on

% Contacts diagram for timestep of interest (rose diagram)
polar(tout,new_rout_contacts/(counts*bin_angles),'b')    % Plot actual values
% Plot anisotropy fit on top 
rho=(1/(2*pi))*(1+contact_a(toi)*cos(2*(theta-contact_theta(toi))));
polar(theta,rho,'r')

% % Contacts diagram of anisotropy fit and counts through time (movie)
% figure
% u=uicontrol('Min',1,'Max',finaltime,'Value',1);
% for k=1:finaltime
%     
%     [tout, rout]=rose(binning_contacts(:,k),angle_bins);
%     new_rout_contacts=zeros(angle_bins,1);
%     new_rout_contacts=cat(2,new_rout_contacts,binning_contacts(:,k));
%     new_rout_contacts=cat(2,new_rout_contacts,binning_contacts(:,k));
%     new_rout_contacts=cat(2,new_rout_contacts,zeros(angle_bins,1));
%     new_rout_contacts=reshape(new_rout_contacts',[1,angle_bins*4]);
% 
%     counts=sum(binning_contacts(:,k));
% 
%     theta=0:0.01:2*pi;
%     radius=0.3;     % Change to the maximum radius needed by the data
%     P = polar(theta, radius * ones(size(theta)));
%     set(P, 'Visible', 'off')
%     hold on
%     
%     % Contacts diagram for current timestep
%     polar(tout,new_rout_contacts/(counts*bin_angles),'b')  % Plot actual values
%     rho=(1/(2*pi))*(1+contact_a(k)*cos(2*(theta-contact_theta(k))));
%     polar(theta,rho,'r')
%     u.Value=k;
%     M(k)=getframe(gcf);
%     hold off
%  end   
% v=VideoWriter(['contacts_mixing_region_',filename,'.avi']);
% v.FrameRate=8;
% open(v)
% writeVideo(v,M)
% close(v)

% Plot rose diagrams for normal forces and calculated anisotropy ~~~~~~~~~~ 

%toi=1;      % Timestep of interest (just 1 timestep)

[tout, rout]=rose(binning_forces_n(:,toi),angle_bins);  % Already the mean
new_rout_n=zeros(angle_bins,1);
new_rout_n=cat(2,new_rout_n,binning_forces_n(:,toi));
new_rout_n=cat(2,new_rout_n,binning_forces_n(:,toi));
new_rout_n=cat(2,new_rout_n,zeros(angle_bins,1));
new_rout_n=reshape(new_rout_n',[1,angle_bins*4]);

% Calculate the average of the averages in each bin
force_n_mean=mean(binning_forces_n(:,toi)); 

figure
theta=0:0.01:2*pi;
radius=2;     % Change to the maximum radius needed by the data
P = polar(theta, radius * ones(size(theta)));
set(P, 'Visible', 'off')
hold on

% Normal forces diagram for current timestep
polar(tout,new_rout_n/force_n_mean,'b')    % Plot actual values
theta=0:0.01:2*pi;
% Plot anisotropy fit
rho=1+fn_a(toi)*cos(2*(theta-fn_theta(toi)));
polar(theta,rho,'r')

% % Contacts diagram of anisotropy fit and counts through time (movie)
% figure
% u=uicontrol('Min',1,'Max',finaltime,'Value',1);
% for k=1:finaltime
%     
%     [tout, rout]=rose(binning_forces_n(:,k),angle_bins);
%     new_rout_n=zeros(angle_bins,1);
%     new_rout_n=cat(2,new_rout_n,binning_forces_n(:,k));
%     new_rout_n=cat(2,new_rout_n,binning_forces_n(:,k));
%     new_rout_n=cat(2,new_rout_n,zeros(angle_bins,1));
%     new_rout_n=reshape(new_rout_n',[1,angle_bins*4]);
% 
%     force_n_mean=mean(binning_forces_n(:,k));
% 
%     theta=0:0.01:2*pi;
%     radius=2;     % Change to the maximum radius needed by the data
%     P = polar(theta, radius * ones(size(theta)));
%     set(P, 'Visible', 'off')
%     hold on
%     
%     % Contacts diagram for current timestep
%     polar(tout,new_rout_n/force_n_mean,'b')  % Plot actual values
%     rho=1+fn_a(k)*cos(2*(theta-fn_theta(k)));
%     polar(theta,rho,'r')
%     u.Value=k;
%     M(k)=getframe(gcf);
%     hold off
%  end   
% v=VideoWriter(['forces_n_mixing_region_',filename,'.avi']);
% v.FrameRate=8;
% open(v)
% writeVideo(v,M)
% close(v)

 
% Plot rose diagrams for tangential forces and calculated anisotropy ~~~~~~ 
%toi=1;      % Timestep of interest

[tout, rout]=rose(binning_forces_t(:,toi),angle_bins);  % Already the mean
new_rout_t=zeros(angle_bins,1);
new_rout_t=cat(2,new_rout_t,binning_forces_t(:,toi));
new_rout_t=cat(2,new_rout_t,binning_forces_t(:,toi));
new_rout_t=cat(2,new_rout_t,zeros(angle_bins,1));
new_rout_t=reshape(new_rout_t',[1,angle_bins*4]);

% Calculate the average of the averages for each bin
force_n_mean=mean(binning_forces_n(:,toi));

figure
theta=0:0.01:2*pi;
radius=0.5;     % Change to the maximum radius needed by the data
P = polar(theta, radius * ones(size(theta)));
set(P, 'Visible', 'off')
hold on

% Tangential forces rose diagram for current timestep
polar(tout,new_rout_t/force_n_mean,'b')    % Still normalize with normals
theta=0:0.01:2*pi;
% Plot anisotropy fit
rho=-sin(2*(theta-ft_theta(toi)));
polar(theta,rho,'r')

% % Contacts diagram of anisotropy fit and counts through time (movie)
% figure
% u=uicontrol('Min',1,'Max',finaltime,'Value',1);
% for k=1:finaltime
%     
%     [tout, rout]=rose(binning_forces_t(:,k),angle_bins);
%     new_rout_t=zeros(angle_bins,1);
%     new_rout_t=cat(2,new_rout_t,binning_forces_t(:,k));
%     new_rout_t=cat(2,new_rout_t,binning_forces_t(:,k));
%     new_rout_t=cat(2,new_rout_t,zeros(angle_bins,1));
%     new_rout_t=reshape(new_rout_t',[1,angle_bins*4]);
% 
%     force_n_mean=mean(binning_forces_n(:,k));
% 
%     theta=0:0.01:2*pi;
%     radius=0.03;     % Change to the maximum radius needed by the data
%     P = polar(theta, radius * ones(size(theta)));
%     set(P, 'Visible', 'off')
%     hold on
%     
%     % Contacts diagram for current timestep
%     polar(tout,new_rout_t/force_n_mean,'b')  % Plot actual values
%     hold on
%     rho=-sin(2*(theta-ft_theta(k)));
%     polar(theta,rho,'r')
%     u.Value=k;
%     M(k)=getframe(gcf);
%     hold off
%  end   
% v=VideoWriter(['forces_t_mixing_region_',filename,'.avi']);
% v.FrameRate=8;
% open(v)
% writeVideo(v,M)
% close(v)

% Coordination Number plots ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Plot contact anisotropy and coordination number through time
t=0:length(contact_theta)-1; 
t=t/8;
a=csvread(['ave_coord_',filename,'.csv'],0,0);
a=a(:,2);   % Pull out only mixing region coordination numbers
[ax,line1,line2]=plotyy(t,a,t,contact_a);
xlim(ax(1),[0 100])
xlim(ax(2),[0 100])
xlabel('Time (s)')
ylabel(ax(2),'Contact Anisotropy')
ylabel(ax(1),'Coordination Number')
line1.LineWidth=2;
line2.LineWidth=2;

% Plot anisotropy and theta differences between contacts and normal forces
[ax,line1,line2]=plotyy(t,fn_a-contact_a,t,(fn_theta-contact_theta)* ...
    (180/pi));
xlim(ax(1),[0 100])
xlim(ax(2),[0 100])
xlabel('Time (s)')
ylabel(ax(1),'Delta a')
ylabel(ax(2),'Delta theta (degrees)')
line1.LineWidth=2;
line2.LineWidth=2;

% Plot thetas in degrees through time
plot(t,contact_theta*(180/pi),t,fn_theta*(180/pi),t,ft_theta*(180/pi), ...
    'LineWidth',2)
legend('contact','normal force','tangential force')
xlim([0 finaltime/8])
xlabel('Time (s)')
ylabel('Theta (degrees)')
