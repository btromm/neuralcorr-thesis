% Figure 1 -- Prove O'Leary Integral control formalism maintains behavior
% quantify how often it works

%% global parameters

% time variables
T_measure = 6e3;
T_grow = 200e3;
numSim = 250;

% leak
Leak_gbar = 0.05;
leak_cell = {'Leak'};

% noise
Ca_target_noise = 30;
initial_condition_noise = 0.01;





[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize();
