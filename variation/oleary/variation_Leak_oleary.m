% Figure 2 -- Variation in g vs. g_leak
clear all;
clc;

% global parameters

T_measure = 20e3;
T_grow = 1e6;
g0 = 1e-1+1e-1*rand(8,1);
numSim = 100;

[x,metrics0] = initialize(T_grow,T_measure,1);

gbars = NaN(8,numSim);
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',0.25*rand(1));
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
variations.plot(gbars, channels);
%savefig('gbarvar');
