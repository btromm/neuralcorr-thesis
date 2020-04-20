% Figure 2 -- Variation in g vs. g_leak
clear all;
clc;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 1000;
initial_condition_noise = 0.01;
leak_cell = {'Leak'};
Leak_gbar = 0.2;

[x,metrics0,channels] = model.initialize(T_grow,T_measure,1,numSim);

% general variation
mRNA_controller = (initial_condition_noise/50)*rand(length(x.get('*Controller.m')),numSim);
mRNA = initial_condition_noise*rand(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);

% specific variation
Leak_gbars = Leak_gbar.*rand(1,numSim);

% storage variables
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
  x.set('*Controller.m',mRNA_controller(:,i)); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbars(i));

  x.integrate;

  Ca_avg(i) = x.get('*Ca_average');
  Ca_tgt(i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

save('gbars_Leak','gbars');
save('IC_Leak','IC');
save('gbars_Leak_proper','g_proper');
save('gbars_Leak_other','g_other');

save('leak_gbars_var','Leak_gbars');

variations.check_successrate(g_proper,numSim)

%variations.plot(gbars, channels);
%savefig('gbarvar');
