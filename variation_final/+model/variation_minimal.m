function [V,time,g0,gbars] = variation_minimal(exp,type)
  %VARIATION_MINIMAL Run any experiment from this thesis, any time, anywhere
  %   exp -- what are we varying? (IC, Leak, tau_m, tau_g, Ca_target)
  %   type -- 1 (voltage trace b4 integration), 2 (voltage trace after integration), 3 (g0 & gbars)

% Global parameters
T_measure = 6e3;
T_grow = 200e3;
numSim = 1000;
leak_cell = {'Leak'};

if strcmp(exp,'Leak')
  Leak_gbar = 0.2.*rand(1,numSim)
else
  Leak_gbar = 0.05;
end
if strcmp(exp,'g_0')
  initial_condition_noise = 0.2;
  reduce = 50;
else
  initial_condition_noise = 0.01;
  reduce = 2.5;
end

if strcmp(exp,'tau_m')
  [x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,3,numSim);
elseif strcmp(exp,'tau_g')
  [x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,2,numSim);
else
  [x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1,numSim);
end

switch exp
case 'Ca_t_a_r_g_e_t'
    Ca_target_noise = 30;
    Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);
end

% Initial condition variation
mRNA_controller = (initial_condition_noise/reduce)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
g0 = initial_condition_noise.*rand(length(channels),numSim);

switch type
case 1 % trace before convergence
  [V,time] = model.trace_before(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels);
  g0 = NaN;
  gbars = NaN;
case 2 % trace after convergence
  [V,time] = model.trace_after(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow,T_measure,metrics0);
  g0 = NaN;
  gbars = NaN;
case 3 % fun with gbars
  % return g0, gbars after sims
  [g0,gbars,g_proper,g_other] = model.get_gbars(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow);
end
