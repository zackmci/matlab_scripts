filename='granular_flow_lube';
timestep=2000;
box_size=1;

cd('/home/zack/Documents/csv_data_files/')

vtpdata=csvread([filename,'.',num2str(timestep),'.csv'],1,0);

% Calculate the total mass of the system
total_mass = sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3));
    
% % Calculate the center of mass in the x direction
% x_mean = (sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3).* ...
%      vtpdata(:,7)))/total_mass;
x_mean=10;
 
% Calculate the center of mass in the y direction
% y_mean = (sum((4/3)*pi()*(vtpdata(:,2)/2).^3 .* vtpdata(:,3).* ...
%      vtpdata(:,8)))/total_mass;
y_mean=10;
 
 
vtpdata(vtpdata(:,7) < x_mean-box_size,:)=[];
vtpdata(vtpdata(:,7) > x_mean+box_size,:)=[];
    
vtpdata(vtpdata(:,8) < y_mean-box_size,:)=[];
vtpdata(vtpdata(:,8) > y_mean+box_size,:)=[];
 
low_left=[x_mean-box_size y_mean-box_size];
low_right=[x_mean+box_size y_mean-box_size];
high_left=[x_mean-box_size y_mean+box_size];
high_right=[x_mean+box_size y_mean+box_size];

ll=sqrt((vtpdata(:,7)-low_left(1)).^2 + (vtpdata(:,8)-low_left(2)).^2);
lr=sqrt((vtpdata(:,7)-low_right(1)).^2 + (vtpdata(:,8)-low_right(2)).^2);
hl=sqrt((vtpdata(:,7)-high_left(1)).^2 + (vtpdata(:,8)-high_left(2)).^2);
hr=sqrt((vtpdata(:,7)-high_right(1)).^2 + (vtpdata(:,8)-high_right(2)).^2);

distances=cat(2,vtpdata,ll);
distances=cat(2,distances,lr);
distances=cat(2,distances,hl);
distances=cat(2,distances,hr);
 
% Lower left particle
[value,ll_i]=min(distances(:,10));
ll_particle=distances(ll_i,:);
% Lower right particle
[value,lr_i]=min(distances(:,11));
lr_particle=distances(lr_i,:);
% Upper left particle
[value,hl_i]=min(distances(:,12));
hl_particle=distances(hl_i,:);
% Upper right particle
[value,hr_i]=min(distances(:,13));
hr_particle=distances(hr_i,:);

dv_dx=((lr_particle(5)-ll_particle(5))/(2*box_size) + (hr_particle(5)-...
    hl_particle(5))/(2*box_size))/2;
du_dy=((hl_particle(4)-ll_particle(4))/(2*box_size) + (hr_particle(4)-...
    lr_particle(4))/(2*box_size))/2;

strain_rate=dv_dx+du_dy

cd('/home/zack/Documents/matlab_scripts/')
 
 