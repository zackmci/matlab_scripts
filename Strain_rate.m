%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Strain_rate (actually it calculates the Stokes number too)
%
% Input csv data generated from res files using Paraview. This file 
%   calculates the Stokes number for the fluid as desribed in Ness & Sun
%   (2015). 
%
% June 25, 2015, modified March 11, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('/home/zack/Documents/csv_data_files/')

filename='granular_flow_lube';
finaltime=9999;      % Last fluid timestep
width=512;          % Width of the fluid domain [cm]
height=128;         % Height of the fluid domain [cm]
diameter=0.5;       % Particle diameter [cm]
rho_p=3.16;          % Particle density [g/cm^3]
mew_f=10;            % Fluid viscosity [poise]
dx=1;               % Grid spacing in x [cm]
dy=1;               % Grid spacing in y [cm]
indicies=transpose(1:width*height); % Create list of indicies for cell
                                    % centers

% Calculating the Stokes Number for all time steps
for time=0:finaltime
    
    time
    
    a=csvread([filename,'.',num2str(time),'.csv'],1,0);
    
    % Get rid of the cells outside of the domain that ParaView saves
    a(a(:,13)<0,:)=[];
    a(a(:,13)>width,:)=[];
    a(a(:,14)<0,:)=[];
    a(a(:,14)>height,:)=[];
    
    u=a(:,4);       % Pull out the u velocities 
    v=a(:,5);       % Pull out the v velocities
    
    % There should be (width+1)*(height+1) rows in a, since the values
    % correspond to vertices

    % Create vectors with each corner for every cell
    ll=indicies+ceil(indicies/width)-1;
    lr=ll+1;
    ul=indicies+width+ceil(indicies/width);
    ur=ul+1;
    
    % Calculate shear rate components
    dv_dx=(((v(lr)-v(ll))/dx)+((v(ur)-v(ul))/dx))/2;
    du_dy=(((u(ul)-u(ll))/dy)+((u(ur)-u(lr))/dy))/2;
    
    % Calculate shear rate and Stokes numbers for each cell
    gamma_dot=dv_dx+du_dy;
    stokes=(rho_p*gamma_dot*diameter^2)/mew_f;
    
    % Create X and Y coordinates for cell centers
    x=mod(indicies,width);
    x(x==0)=width;
    y=ceil(indicies/width);

    % Create data to export for Paraview
    data=cat(2,x,y);
    data=cat(2,data,stokes);
    headers={'Position:0','Position:1','Stokes'};
    csvwrite_with_headers(['Viscous_stokes.',filename,'.',num2str(time),...
        '.csv'], data, headers,0,0);
    
%      a(:,1:6)=[];    % Remove EPg, Pg, P*, and duplicate Ug, Vg, Wg
%      a(:,3:6)=[];    % Remove Wg, Tg, Xg1, and Scalar values
%      a(:,5)=[];      % Remove Z from points
% %     % All that's left now is: Ug, Vg, Wg, X, Y,for the cell vertices
       
%     headers={'Velocity:0', 'Velocity:1', 'Velocity:2', 'Position:0', ...
%     'Position:1', 'Position:2', 'Shear_rate', 'Stokes'};


%     
%     % Get rid of the cells outside of the domain that ParaView saves
%     a(a(:,3)<0,:)=[];
%     a(a(:,3)>width,:)=[];
%     a(a(:,4)<0,:)=[];
%     a(a(:,4)>height,:)=[];
%     
% 
%     a=cat(2,a,nan(size(a,1),1));
%     
%     for i=0:max(a(:,4))-1
%         for j=0:max(a(:,5))-1
%             
%             a_loop=a(a(:,4)==i,:);
%             a_loop=a_loop(a_loop(:,5)==j,:);
%             
%             b_loop=a(a(:,4)==i+1,:);
%             b_loop=b_loop(b_loop(:,5)==j,:);
%             
%             c_loop=a(a(:,4)==i,:);
%             c_loop=c_loop(c_loop(:,5)==j+1,:);
%             
%             shear_rate=(b_loop(2)-a_loop(2))+(c_loop(1)-a_loop(1));
%             %  St_v=shear_rate*(3.3*(0.4^2))/2;
%             
%             row=find(a(:,4)==i & a(:,5)==j);
%             % a(row,end)=St_v;
%             a(row,end)=shear_rate;
%             
%         end
%     end
%     
%     a=a(~isnan(a(:,end)),:);
%     stokes_factor=(rho_p*diameter^2)/mew_f;
%     a=cat(2,a,a(:,end)*stokes_factor);
%     
    %
    % b=a;
    % b(:,4)=b(:,4)-1;
    % b(b(:,4)<0,:)=[];
    %
    % c=a;
    % c(:,5)=c(:,5)-1;
    % c(c(:,5)<0,:)=[];
    %
    % a_compl=a(:,4)+1i*a(:,5);
    % b_compl=b(:,4)+1i*b(:,5);
    % c_compl=c(:,4)+1i*c(:,5);
    %
    % [aa bb]=meshgrid(a_compl, b_compl);
    % distance=aa-bb;
    % [min_distance min_index]=min(distance);
    % new_a=cat(2,a,transpose(abs(min_distance)));
    % new_a=cat(2,new_a,transpose(min_index));
    %
    % [aa cc]=meshgrid(a_compl, c_compl);
    % distance=aa-cc;
    % [min_distance min_index]=min(distance);
    % new_a=cat(2,new_a,transpose(abs(min_distance)));
    % new_a=cat(2,new_a,transpose(min_index));
    %
    % new_a(new_a(:,7)>0,:)=[];
    % new_a(new_a(:,9)>0,:)=[];
    
    % shear_rate=(b(new_a(:,8),2)-new_a(:,2))/1+(c(new_a(:,10),1)-new_a(:,1))/1;
    % new_a=cat(2,new_a,shear_rate);
    % new_a(:,7)=[];
    %
    % stokes_factor=(3.3*(0.4)^2)/2;
    % new_a=cat(2,new_a,new_a(:,end)*stokes_factor);
 
end

cd('/home/zack/Documents/matlab_scripts/')

scatter(data(:,1),data(:,2),10,data(:,3))
xlim([0 256])
ylim([0 128])
