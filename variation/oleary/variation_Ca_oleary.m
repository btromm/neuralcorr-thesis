% Figure 4 -- Variation in Ca_target

clear all;

% global parameters

T_measure = 6e3;
T_grow = 200e3;
numSim = 50;
Leak_gbar = 0.05;
g0 = 1e-1+1e-1*rand(8,1); %set once and fuhget about it
Ca_target_noise = 2;

[x,metrics0,channels,Ca_target0,tau_ms,tau_gs] = model.initialize(T_grow,T_measure,1);

Ca_target = (ones(numSim,1)*Ca_target0)+(1+randn(numSim,1).*Ca_target_noise);
gbars = NaN(8,numSim);
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',g0); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbar);
  x.set('AB.Ca_target',Ca_target(i))
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

variations.Ca_plot(gbars,channels,Ca_target,'Calcium Target');
