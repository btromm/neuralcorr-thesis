% Figure 4 -- Variation in Ca_target

clear all;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
Leak_gbar = 0.05;
g0 = 1e-1+1e-1*rand(8,1); %set once and fuhget about it
Ca_target_noise = 30;
numSim = 10;

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1);

Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);
%Ca_target_min = 10;
%Ca_target_max = 200;
%Ca_target = repelem(linspace(Ca_target_min,Ca_target_max,Ca_target_max/5),20); %run 20 sims of each target
%numSim = length(Ca_target);

gbars = NaN(8,numSim);
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_s = NaN(2,numSim);

for i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
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

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

%variations.Ca_plot(gbars_noleak,channels,Ca_target,'Calcium Target');
%variations.corr_plot(gbars_noleak,channels);
