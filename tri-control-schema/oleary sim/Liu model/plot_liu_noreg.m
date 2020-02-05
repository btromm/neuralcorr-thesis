%%% load in run data
%keep('rand_gs','liu_final_gs');
reload = 0;

% Load models and pull out the maximal conductances
if reload==1
    tic;
    clear;
    load 'd:/Data/Correlations in conductances/jons_final_models_bounded.mat';
    liu_neurons = neurons;
    liu_max = max(liu_neurons.max_gs);
    liu_min = min(liu_neurons.max_gs);
    liu_gs = liu_neurons.max_gs(:,1:7);

    load 'd:/Data/Correlations in conductances/2e6_rand_models.mat'; %takes 3 min
    target_sensor_vals = all(neurons.mean_sensors < 0.11 & ...
                          neurons.mean_sensors > 0.09 , 2);
    target_neurons = find(target_sensor_vals);
    rand_gs = neurons.max_gs(target_neurons,1:7);    
    
    load 'd:/Data/Correlations in conductances/ADHR_runs_tenth_table_one_hour.mat';
    % bound to range of liu runs
    nlim = all(neurons.max_gs <= repmat(liu_max,length(neurons.type),1),2)...
        & all(neurons.max_gs >= repmat(liu_min,length(neurons.type),1),2)...
        & all(neurons.mean_sensors < 0.11 & neurons.mean_sensors > 0.09 , 2);
    target_neurons = find(nlim);
    flipped_gs = neurons.max_gs(target_neurons,1:7);    
    toc
end

%%% SIMULATION SETTINGS %%%
tMin = 0;        % [ms]
tMax = 2000;    % [ms]
dt   = 0.02;     % [ms]
res  = 0.2;     % [ms]
ADHR_switch = 0; % boolean (1 if ON, any other value sets to off)
simulationParams = [tMax; dt; res; ADHR_switch;1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% MAXIMAL CONDUCTANCE SETTINGS %%%
g_leak     = 0.01;
ind = floor(rand*length(rand_gs));
gVec = [rand_gs(ind,:) g_leak]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

[~,state] = mexLiuModel(simulationParams,gVec,sensorVec,regMap);
v = state(3000:end,1);
t = linspace(0,length(v)*res,length(v));

plotstart = find((v<-50),1,'first');
plotend = plotstart+3000;
clf;
plot(t(plotstart:plotend),v(plotstart:plotend), 'color', [0.4 0.4 0.5], 'linewidth', 2);
set(gca,'ylim',[-80,50]);
str = strcat('gNa, gCaT, gCaS, gKA, gKCa, gKd, gH = ',num2str(gVec'));
title(str);
sizefig 1x2;
