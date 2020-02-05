function [t,state] = runLiuModel_withADHR(conductance_set,...    % int or vec
                                          t_adhr_delay,...       % in [ms]
                                          t_adhr_runtime,...     % in [ms]
                                          adhr_time_constant,... % in [ms]
                                          plot_verbosity)        % integer

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

%%% FIRST SIMULATION - ADHR OFF %%%
tMax = t_adhr_delay;  % [ms]
dt   = 0.02;          % [ms]
res  = 1;             % [ms]
ADHR_switch = 0; % boolean (1 if ON, any other value sets to off)
simulationParams = [tMax; dt; res; ADHR_switch;adhr_time_constant];

[t_off,state_off] = mexLiuModel(simulationParams,gVec,sensorVec,regMap);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% SECOND SIMULATION - ADHR ON %%%
tMax = t_adhr_runtime;  % [ms]
dt   = 0.02;            % [ms]
res  = 5e3;               % [ms]
ADHR_switch = 1; % boolean (1 if ON, any other value sets to off)
simulationParams = [tMax; dt; res; ADHR_switch;adhr_time_constant];

[t_on,state_on] = mexLiuModel(simulationParams,gVec,sensorVec,regMap,state_off(end,:)');
%%%%%%%%%%%%%%%%%%%%%%%%%%%

t = [t_off; (t_on+t_off(end)+res)];
state = [state_off; state_on];

if plot_verbosity > 0
  % The history for the maximal conductances:
  max_g_Na = state(:,3);
  max_g_CaT = state(:,6);
  max_g_CaS = state(:,9);
  max_g_A = state(:,12);
  max_g_KCa = state(:,15);
  max_g_Kd = state(:,18);
  max_g_H = state(:,21);
  g_leak = state(:,24);
  G = [max_g_Na, max_g_CaT, max_g_CaS, max_g_A, max_g_KCa, max_g_Kd, max_g_H, g_leak];
    
  figure;
  subplot(2,1,1)
  plot(t/1000,state(:,1))
  ylabel('Membrane Potential [mV]')
  xlabel('time [seconds]')
  subplot(2,1,2)
  plot(t/1000,G)
  ylabel('Maximal Conductance [mS/cm^2]')
  xlabel('time [seconds]')
  legend('Na','CaT','CaS','A','KCa','Kd','H','leak')
end