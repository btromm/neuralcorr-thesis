% Figure 4 -- Variation in Ca_target

clear all;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
Leak_gbar = 0.05;
Ca_target_noise = 30;
initial_condition_noise = 0.01;
numSim = 250;
leak_cell = {'Leak'};

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1,numSim);

Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);
%Ca_target_min = 10;
%Ca_target_max = 200;
%Ca_target = repelem(linspace(Ca_target_min,Ca_target_max,Ca_target_max/5),20); %run 20 sims of each target
%numSim = length(Ca_target);

gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_s = NaN(2,numSim);

for i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',IC(:,i));
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,i));
    end
  end
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('AB.Ca_target',Ca_target(i))

  x.integrate;

  Ca_s(1,i) = x.get('*Ca_average');
  Ca_s(2,i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end
save('gbars_Ca','gbars');
save('IC_Ca','IC');

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

%variations.Ca_plot(gbars_noleak,channels,Ca_target,'Calcium Target');
%variations.corr_plot(gbars_noleak,channels);
