% Figure 4 -- Variation in Ca_target

clear all;
clc;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
Leak_gbar = 0.05;
Ca_target_noise = 30;
initial_condition_noise = 0.01;
numSim = 1000;
leak_cell = {'Leak'};

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1,numSim);

% general variation
mRNA_controller = (initial_condition_noise/50)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);

% specific variation
Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);

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
  x.set('*Controller.m',mRNA_controller(:,i));
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('AB.Ca_target',Ca_target(i))

  x.integrate;

  Ca_avg(i) = x.get('*Ca_average');
  Ca_tgt(i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

save('gbars_Ca','gbars');
save('gbars_Ca_proper','g_proper');
save('gbars_Ca_other','g_other');
save('IC_Ca','IC');

variations.check_successrate(g_proper,numSim)
%variations.Ca_plot(gbars_noleak,channels,Ca_target,'Calcium Target');
%variations.corr_plot(gbars_noleak,channels);
