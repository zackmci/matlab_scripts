clear all;

d = 0.005;  % Particle diameter
mu = 1;     % Fluid viscosity
ros = 3160; % Average density of particles
rol = 2650; % Density of liquid
g = 9.81;   % Gravitational acceleration
Ui = 1;     % Initial guess for velocity
Um = 0.5;   % Introducing the falling velocity term for a single particle.

% Loop to calculate the Reynolds number, the drag coefficint, and the 
% falling velocity.  This is used to iterate the falling velocity. 
% The Reynolds number is used to determine the regime of the slurry
% regieme. The drag coefficient and the falling velocity are used to
% calculate the slurry velocity.
while (Um ~= Ui)
    Re = d*Ui*rol/mu;
    Ui = Um;
    Cd = 24/Re*(1+0.15*Re^(0.687))+0.42/(1+42500*Re^(-1.16));
    Um = (8*g*d/2*abs(ros-rol)/(3*rol*Cd))^(1/2);
end

c = 0.518;    % The volume fraction
Ss = ros/rol; % The density ratio
Vinf = (4*g*d*(Ss-1)/(3*Cd))^(1/2);  % The terminal velocity of the slurry
Vs = Vinf*(1-c)^4.7;  % The slurry velocity
