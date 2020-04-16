% Figure 5 -- Variation in mRNA initial concentrations
clc;
clear all;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 100;
Leak_gbar = 0.05;
g0 = 1e-1+1e-1*rand(8,1);

[x,metrics0] = model.initialize(T_grow,T_measure,1);

gbars = NaN(8,numSim);
mRNA = 1e-2.*rand(8,numSim)+1e-3;
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbar);
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,i));
    end
  end
  x.integrate;

  % check that it has converged, and that the bursts are OK
  if abs(x.AB.Ca_target - x.AB.Ca_average)/x.AB.Ca_target > .1
    disp('Model did not converge')
    continue
  end

  % measure metrics
  x.set('t_end',T_measure);
  [V,Ca] = x.integrate;


  metrics = xtools.V2metrics(V,'sampling_rate',10);

  if (metrics0.burst_period - metrics.burst_period)/metrics0.burst_period > .2
    disp('Burst periods not OK')
    continue
  end

  if (metrics0.duty_cycle_mean - metrics.duty_cycle_mean)/metrics0.duty_cycle_mean > .1
    disp('Duty cycle not OK')
    continue
  end

  gbars(:,i) = x.get('*gbar');
end
variations.IC_plot(gbars,channels,mRNA,' mRNA initial');
%savefig('gbarvar');
