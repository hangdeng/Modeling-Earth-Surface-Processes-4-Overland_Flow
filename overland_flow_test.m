 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % This code is for simulating rainfall, infiltration and runoff on 1D 
 % hillslope. Written by Hang Deng. Ideas from class.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
figure(1)
figure(2)
clf

%% initialize
% parameters
% Rain and Infiltration
R = 1.5; % rainfall rate/yr; meter/year
I = 75; % infiltration 
% inch/hr
h_init = 0.1; % initial thin later of water (m) 
g = 9.8; % gravity acceleration 
n = 0.03; % surface roughness

% Time steps
tmax = 2000;
dt = 0.02;
t = 0:dt:tmax;

% distance steps
xmax = 1e5;
dx = 1000;
x = 0:dx:xmax;

% initial topography
zmax = 1000; % meter
S = 0.01; % slope
z = zmax - S*x; 

% Creating arrays
H = zeros(size(x)); % H array

% Ztotal = H(water) + z(elevation)
Z = z + H;

% plot steps
nplot = 50;
tplot = tmax/nplot;
%%%%% go to model %%%%%%
 
%% loop
for i = 1:length(t)
    % calculate slope
    dzdx = diff(Z)/dx;
    Se = dzdx;
    %Se = [Se Se(end)];
    
    % interpolate H to cell edges
    Hedge = H(1:end-1)+0.5*diff(H);
    
    % laminar flow?
    u=(1/n).*(Hedge.^(2/3)).*(Se.^(1/2)); 
    % law of the wall, von karmin function~0.408, turbulent flow
    % u = (sqrt(g.*Hedge.*Se)/0.408).*((log(Hedge/zstar))-0.74); 
    % u = sqrt(8*g.*Hedge.*Se/f);
    % discharge 
    Q = u .* Hedge;
    % flux
    dQdx = diff(Q)/dx;
    
    % H change with time
    dHdt = -dQdx + R*dt; %- I;
    dHdt = [dHdt(1) dHdt dHdt(end)];
    % update H
    H = H + h_init - dHdt.*dt;
    H = max(H,0); % surface flow thickness over 0
    
    % update Z
    Z = z + H;
    
    if rem(t(i),tplot)==0
        disp(['Time: ' num2str(t(i))]);
        figure(1)
        plot(x/1000,Z,'r','linewidth',2);
        hold on
        plot(x/1000,z,'g--','linewidth',1);
        xlabel('Distance [km]','Fontsize',12)
        ylabel('Elevation [m]','Fontsize',12)
        ylim([0 4000]);
        legend('Total Elevation','Bedrock Elevation');
        %M(:,nframe) = getframe(gcf);
        pause(0.02)  
        hold off    
        
    end       
 
end
%% plotting figure(2)
figure(2)
plot(x/1000,H,'b','linewidth',2);
xlabel('distance (km)','fontsize',12);
ylabel('discharge','fontsize',12);
legend('hydrograph(?)');