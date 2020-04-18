% Figure 2 -- Variation in g vs. g_leak
clear all;
clc;

% global parameters

T_measure = 20e3;
T_grow = 1e6;
numSim = 250;
initial_condition_noise = 0.01;
leak_cell = {'Leak'};

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1,numSim);

gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);

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
save('IC_Leak','IC');

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

%variations.plot(gbars, channels);
%savefig('gbarvar');
