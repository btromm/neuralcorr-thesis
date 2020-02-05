function [t v] = v_trace_liu(gVec,tMax,dt,resin)

%%% SIMULATION SETTINGS %%%
%tMin = 0;        % [ms]
%tMax = 2000;    % [ms]
%dt   = 0.02;     % [ms]
res  = resin*dt;     % [ms]
ADHR_switch = 0; % boolean (1 if ON, any other value sets to off)
simulationParams = [tMax; dt; res; ADHR_switch;1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

[t,state] = mexLiuModel(simulationParams,gVec,sensorVec,regMap);
v = state(:,1);

end