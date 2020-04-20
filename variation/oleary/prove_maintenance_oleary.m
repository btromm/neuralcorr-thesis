% Figure 1 -- Prove O'Leary Integral control formalism maintains behavior
% quantify how often it works
clear all;
clc;
%% global parameters

% time variables
T_measure = 6e3;
T_grow = 100e3;
numSim = 10;

% leak
Leak_gbar = 0.05;
leak_cell = {'Leak'};

% noise
initial_condition_noise = 0.2;
mRNA = 1e-2.*rand(8,numSim)+1e-3;

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1,numSim);

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
  x.set('*Controller.m',(initial_condition_noise/50)*rand(length(x.get('*Controller.m')*0+1),1));
  x.set('AB.Leak.gbar',Leak_gbar);


  data = x.integrate;
  Ca_avg = x.get('*Ca_average');
  Ca_tgt = x.get('*Ca_target');
  gbars = x.get('*gbar');
  x.set('t_end',T_measure);
  data_measure = x.integrate;
  metrics_V = data_measure.AB.V;

  model_ok = model.metric_check(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt)
  if model_ok == 1
    hasbeenplotted = 1;
    variations.trace_plot(x,data,channels,'Standard Integral Control Scheme')
  end
  idx = idx + 1;
end

gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_avg = NaN(1,numSim);
Ca_tgt = NaN(1,numSim);
parfor i = 1:numSim

  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',IC(:,i));
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,i));
    end
  end
  x.set('*Controller.m',(initial_condition_noise/50)*rand(length(x.get('*Controller.m')*0+1),1));
  x.set('AB.Leak.gbar',Leak_gbar);

  x.integrate;

  Ca_avg(i) = x.get('*Ca_average');
  Ca_tgt(i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

save('gbars_prove','gbars');
save('gbars_prove_proper','g_proper');
save('gbars_prove_other','g_other');
save('IC_prove','IC');

success_rate = variations.check_successrate(g_proper,numSim)
