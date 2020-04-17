% Figure 8 -- Variation in IntegralController initial mRNA concentration

clear all;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 500;
Leak_gbar = 0.05;
g0 = 1e-1+1e-1*rand(8,1);

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1);

mRNA = 1e-2.*rand(7,numSim)+1e-3;
gbars = NaN(8,numSim);
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_s = NaN(2,numSim);

parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('*Controller.m',mRNA(:,i));

  x.integrate;

  Ca_s(1,i) = x.get('*Ca_average');
  Ca_s(2,i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end
save('gbars_controller_mRNA','gbars');

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

%variations.IC_plot(gbars,channels,mRNA,'Controller mRNA');
%savefig('gbarvar');
