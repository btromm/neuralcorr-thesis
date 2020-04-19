% Figure 7 -- Variation in IntegralController translation timescale

clear all;
clc;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 250;
Leak_gbar = 0.05;
initial_condition_noise = 0.01;
leak_cell = {'Leak'};

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,2,numSim);

gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);
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
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
  for c = 1:length(channels)
    if ~ismember(channels{c},leak_cell)
      x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_g'),tau_gs(c,i));
    end
  end

  x.integrate;

  Ca_avg(i) = x.get('*Ca_average');
  Ca_tgt(i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

save('gbars_controller_taug','gbars');
save('IC_controller_taug','IC');
save('gbars_controller_taug_proper','g_proper');
save('gbars_controller_taug_other','g_other');

%variations.IC_plot(gbars,channels,tau_gs,'tau_g');
%savefig('gbarvar');
