% Figure 2 -- Variation in g vs. g_leak
clear all;
clc;

% global parameters

T_measure = 20e3;
T_grow = 1e6;
g0 = 1e-1+1e-1*rand(8,1);
numSim = 100;

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1);

gbars = NaN(8,numSim);
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',0.25*rand(1));

  x.integrate;

  Ca_s(1,i) = x.get('*Ca_average');
  Ca_s(2,i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end
save('gbars_Leak','gbars');

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

%variations.plot(gbars, channels);
%savefig('gbarvar');
