function [t,state] = runLiuModel_noADHR(conductance_set,...   % integer or vector
                                        t_max_in,...          % in [ms]
                                        plot_verbosity,...    % integer
                                        resolution,...  % [ms] (optional)
                                        initial_state)  % vector (optional)

% If conductance_set is an integer, then load the condutances. Otherwise,
% if conductance_set is a vector, just use that vector to specify g_max.
if isscalar(conductance_set)
  gVec = loadConductances(conductance_set);
else
  gVec = conductance_set;
end

%%% ADHR SENSOR PARAMETERS %%%
sensorVec = [0.1;    % target %% FAST SENSOR %%
             10;     % G_max
             0.5;    % tauM
             1.5;    % tauH
             14.2;   % Z_m
             9.8;    % Z_h
             0.1;    % target %% SLOW SENSOR %%
             3;      % G_max
             50;     % tauM
             60;     % tauH
             7.2;    % Z_m
             2.8;    % Z_h
             0.1;    % target %% DC SENSOR %%
             1;      % G_max
             500;    % tauM
             1;      % tauH
             3;      % Z_m
             3];     % Z_h
% Map to connect the ADHR sensors to the ion channels
%         Na    CaT   CaS    A    Kca   Kd     H    leak
regMap = [+1     0     0     0     0    +1     0     0;   % "A" - Fast
           0    +1    +1    -1    -1    -1    +1     0;   % "B" - Slow
           0     0     0    -1    -1     0    +1     0];  % "C" - DC
regMap = regMap'; % Transpose to import into c++

%%% SIMULATION PARAMETERS %%%
tMax = t_max_in; % [ms]
dt   = 0.02;     % [ms]
if nargin<4
  res = resolution;
else
  res  = 0.5;      % [ms]
end
ADHR_switch = 0; % boolean (1 if ON, any other value sets to off)
simulationParams = [tMax; dt; res; ADHR_switch;1];

if(nargin<5)
  [t,state] = mexLiuModel(simulationParams,gVec,sensorVec,regMap);
else
  [t,state] = mexLiuModel(simulationParams,gVec,sensorVec,...
                          regMap,initial_state);
end

if plot_verbosity > 0
  % Maximal conductances:
  max_g_Na = state(1,3);
  max_g_CaT = state(1,6);
  max_g_CaS = state(1,9);
  max_g_A = state(1,12);
  max_g_KCa = state(1,15);
  max_g_Kd = state(1,18);
  max_g_H = state(1,21);
  g_leak = state(1,24);
  G = [max_g_Na, max_g_CaT, max_g_CaS, max_g_A, max_g_KCa, max_g_Kd, max_g_H, g_leak];
    
  figure;
  subplot(3,1,1)
  plot(t/1000,state(:,1),'-b')
  ylabel('Membrane Potential [mV]')
  subplot(3,1,2)
  plot(t/1000,state(:,2),'-g')
  ylabel('Ca [uM]')
  xlabel('time [seconds]')
  subplot(3,1,3)
  bar(G)
  ylabel('Maximal Conductance [mS/cm^2]')
  set(gca,'XTickLabel',{'Na','CaT','CaS','A','KCa','Kd','H','leak'})
  
  % Sensors
  figure;
  subplot(3,1,1)
  title('FAST SENSOR')
  hold on
  plot(t/1000,10*(state(:,27).^2).*state(:,28),'-b')
  plot(t/1000,moving(10*(state(:,27).^2).*state(:,28),tMax/4),'-r','LineWidth',2);
  ylim([0 0.3])
  subplot(3,1,2)
  hold on
  title('SLOW SENSOR')
  plot(t/1000,3*(state(:,29).^2).*state(:,30),'-b')
  plot(t/1000,moving(3*(state(:,29).^2).*state(:,30),tMax/4),'-r','LineWidth',2);
  ylim([0 0.3])
  subplot(3,1,3)
  hold on
  title('DC SENSOR')
  plot(t/1000,1*(state(:,31).^2).*state(:,32),'-b')
  avg = moving(1*(state(:,31).^2).*state(:,32),tMax/4);
  plot(t/1000,avg,'-r','LineWidth',1.5);
%   V = state(:,1); g_1 = state(:,6); g_2 = state(:,9); m_1 = state(:,7); h_1 = state(:,8); m_2 = state(:,10); h_2 = state(:,11);  
%   V_ca = (8.314*296.65/(96.485*2)).*log(3000./state(:,2)); I_ca = g_1.*(m_1.^3).*h_1.*(V-V_ca) + g_2.*(m_2.^3).*h_2.*(V-V_ca);
%   DC_inf = (1 ./ (1 + exp(3 + I_ca))).^2; 
%   plot(t/1000,DC_inf,'-m','LineWidth',3);
  ylim([0 2*mean(avg)])
  xlabel('time [seconds]')
  legend('Sensor','Average')
end