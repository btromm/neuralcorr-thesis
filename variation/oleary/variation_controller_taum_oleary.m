% Figure 6 -- Variation in IntegralController transcription timescale

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

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,3,numSim);


% general variation
mRNA_controller = (initial_condition_noise/2.5)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);

% specific variation
tau_ms = abs((repmat(tau_ms,1,numSim)*0.75)+((repmat(tau_ms,1,numSim)).*(rand(length(channels),numSim))));

gbars = NaN(8,numSim);
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
      x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_m'),tau_ms(c,i));
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

save('gbars_controller_taum','gbars');
save('IC_controller_taum','IC');
save('gbars_controller_taum_proper','g_proper');
save('gbars_controller_taum_other','g_other');
save('var_tau_ms','tau_ms');

variations.check_successrate(g_proper,numSim)
%variations.IC_plot(gbars,channels,tau_ms,'tau_m');
%savefig('gbarvar');
