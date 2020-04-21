% Figure 9 -- prove FSD integral controller model works

clear all;
clc;

%% set global parameters
T_measure = 6e3;
T_grow = 400e3;
numSim = 10;

% leak
Leak_gbar = 0.05;
leak_cell = {'Leak'};

% noise
initial_condition_noise = 0.2;

%% initialize model
[x,metrics0,channels,FTarget,STarget,DTarget,tau_gs] = model.initialize_FSD(T_grow,T_measure,1,numSim);

% general variation
mRNA_controller = (initial_condition_noise/50)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);

model_ok = 0;
idx = 1;
while(model_ok == 0)
  x.set('t_end',T_grow);
  x.dt = 0.1;
  x.output_type = 1;
  x.set('*gbar',IC(:,idx));
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,idx));
    end
  end
  x.set('*Controller.m',mRNA_controller(:,idx));
  x.set('AB.Leak.gbar',Leak_gbar);


  data = x.integrate;
  F = x.get('*FastSensor.X');
  S = x.get('*SlowSensor.X');
  D = x.get('*DCSensor.X');
  gbars = x.get('*gbar');
  x.set('t_end',T_measure);
  data_measure = x.integrate;
  metrics_V = data_measure.AB.V;

  model_ok = model.metric_check_FSD(gbars,metrics_V,metrics0,F,FTarget,S,STarget,D,DTarget)
  if model_ok == 1
    hasbeenplotted = 1;
    variations.trace_plot(x,data,channels,'FSD Integral Control Scheme')
  end
  idx = idx + 1;
end
