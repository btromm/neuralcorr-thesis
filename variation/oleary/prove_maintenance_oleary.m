% Figure 1 -- Prove O'Leary Integral control formalism maintains behavior
% quantify how often it works

%% global parameters

% time variables
T_measure = 6e3;
T_grow = 200e3;
numSim = 250;

% leak
Leak_gbar = 0.05;
leak_cell = {'Leak'};

% noise
initial_condition_noise = 0.01;

% initialize data files
gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
IC = initial_condition_noise.*rand(length(channels),numSim);
metrics_V = NaN((T_measure/x.dt),numSim);
Ca_s = NaN(2,numSim);

hasbeenplotted = 0;

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize();

for i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',IC(:,i));
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('*Controller.m',0); %always start m from zero
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,i));
    end
  end

  x.integrate;

  Ca_s(1,i) = x.get('*Ca_average');
  Ca_s(2,i) = x.get('*Ca_target');
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;
  metrics_V(:,i) = V;

  gbars(:,i) = x.get('*gbar');

  % plot trace if metrics are ok
  if (hasbeenplotted == 0)
    model_ok = metric_check(gbars(:,i),metrics_V(:,i),Ca_s(:,i))
    if model_ok = 1
      hasbeenplotted = 1;
      trace_plot
    end
  end
end

[g_proper,g_other] = model.filter_gbars(gbars,metrics_V,metrics0,Ca_s,numSim);

save('gbars_prove','gbars');
save('gbars_prove_proper','g_proper');
save('gbars_prove_other','g_other');
save('IC_prove','IC');

success_rate = variations.check_successrate()
