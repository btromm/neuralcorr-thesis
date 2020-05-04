function [V,time,g0,gbars,g_proper,g_other,var] = variation_minimal(exp,type,var)
  %VARIATION_MINIMAL Run any experiment from this thesis, any time, anywhere
  %   exp -- what are we varying? (IC, Leak, tau_m, tau_g, Ca_target)
  %   type -- 1 (voltage trace b4 integration), 2 (voltage trace after integration), 3 (g0 & gbars)

% Global parameters
T_measure = 6e3;
T_grow = 200e3;
numSim = 1000;
leak_cell = {'Leak'};

if strcmp(exp,'Leak')
  if exist('var','var') == 1
    Leak_gbar = var;
  else
    Leak_gbar = 0.2.*rand(1,numSim)
    prompt = 'Do you want to save Leak_gbar variation? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
      str = 'Y';
    end
    if strcmp(str,'Y')
      save('Leak_var','Leak_gbar');
    end
  end
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
  if exist('var','var') == 1
    tau_ms = var;
  else
    tau_ms = abs((repmat(tau_ms,1,numSim)*0.75)+((repmat(tau_ms,1,numSim)).*(rand(length(channels),numSim))));
    prompt = 'Do you want to save tau_m variation? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
      str = 'Y';
    end
    if strcmp(str,'Y')
      save('tau_m_var','tau_ms');
    end
  end
elseif strcmp(exp,'tau_g')
  [x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,2,numSim);
  if exist('var','var') == 1
    tau_gs = var;
  else
    tau_noise = 2e3;
    tau_gs = (tau_noise.*rand(8,numSim)-tau_noise/2)+tau_gs(1);
    prompt = 'Do you want to save tau_g variation? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
      str = 'Y';
    end
    if strcmp(str,'Y')
      save('tau_g_var','tau_gs');
    end
  end
else
  [x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1,numSim);
end

if(strcmp(exp,'Ca_t_a_r_g_e_t'))
  if exist('var','var') == 1
    Ca_target = var;
  else
    Ca_target_noise = 30;
    Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);
    prompt = 'Do you want to save Ca_target variation? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
      str = 'Y';
    end
    if strcmp(str,'Y')
      save('Ca_target_var','Ca_target');
    end
  end
else
  Ca_target = repmat(Ca_target0,numSim,1);
end

% Initial condition variation
mRNA_controller = (initial_condition_noise/reduce)*rand(length(x.get('*Controller.m')),numSim);
save(strcat('mRNA_controller',exp),'mRNA_controller');
mRNA = initial_condition_noise*rand(8,numSim);
save(strcat('mRNA',exp),'mRNA');
g0 = initial_condition_noise.*rand(length(channels),numSim);
save(strcat('g0',exp),'g0');

switch type
case 1 % trace before convergence
  [V,time] = model.trace_before(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,Ca_target);
  g0 = NaN;
  gbars = NaN;
case 2 % trace after convergence
  [V,time] = model.trace_after(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow,T_measure,metrics0,Ca_target);
  g0 = NaN;
  gbars = NaN;
case 3 % fun with gbars
  [V,time] = model.get_gbars(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow,T_measure,metrics0,numSim,Ca_target);
end
