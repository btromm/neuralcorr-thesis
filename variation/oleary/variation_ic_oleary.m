% Figure 3 -- Variation in initial conditions (gbars and mRNA)

clear all;
clc;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 250;
Leak_gbar = 0.05;
initial_condition_noise = .2;
leak_cell = {'Leak'};

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1,numSim);

mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);
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
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbar);

  x.integrate;

  Ca_avg(i) = x.get('*Ca_average');
  Ca_target(i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

save('gbars_IC','gbars');
save('IC_IC','IC');
save('gbars_IC_proper','g_proper');
save('gbars_IC_other','g_other');

%variations.CV_plot(IC,g_proper);
%variations.corr_plot(IC,g_proper,channels);
%savefig('gbarvar');
