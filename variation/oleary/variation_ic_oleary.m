% Figure 3 -- Variation in initial conditions (gbars and mRNA)

clear all;

% global parameters

T_measure = 6e3;
T_grow = 400e3;
numSim = 50;
Leak_gbar = 0.05;
initial_condition_noise = .05;

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1);

mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);
gbars = NaN(8,numSim);
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_s = NaN(2,numSim);

parfor i = 1:numSim
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

  x.integrate;

  Ca_s(1,i) = x.get('*Ca_average');
  Ca_s(2,i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end
save('gbars_IC','gbars');

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

variations.CV_plot(IC,gbars,channels)
%variations.IC_plot(gbars,channels,IC,' initial gbar');
%savefig('gbarvar');
