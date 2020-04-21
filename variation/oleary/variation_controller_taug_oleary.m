% Figure 7 -- Variation in IntegralController translation timescale

clear all;
clc;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 1000;
Leak_gbar = 0.05;
initial_condition_noise = 0.01;
leak_cell = {'Leak'};
tau_noise = 2e3;

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,2,numSim);

% general variation
mRNA_controller = (initial_condition_noise/2.5)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);

%specific variation
%tau_gs = abs((repmat(tau_gs,1,numSim))+((repmat(tau_gs,1,numSim)).*(randn(length(channels),numSim))));
tau_gs = (tau_noise.*rand(8,numSim)-tau_noise/2)+tau_gs(1);

gbars = NaN(8,numSim);
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
  x.set('*Controller.m',mRNA_controller(:,i));
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
save('var_tau_gs','tau_gs');

variations.check_successrate(g_proper,numSim)
%variations.IC_plot(gbars,channels,tau_gs,'tau_g');
%savefig('gbarvar');
