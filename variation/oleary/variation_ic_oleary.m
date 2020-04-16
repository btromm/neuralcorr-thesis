% Figure 3 -- Variation in initial conditions

clear all;

% global parameters

T_measure = 6e3;
T_grow = 400e3;
numSim = 50;
Leak_gbar = 0.05;
initial_condition_noise = .05;

[x,metrics0] = initialize(T_grow,T_measure,1);

gbars = NaN(8,numSim);
IC = initial_condition_noise.*rand(length(channels),numSim);
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',IC(8,i)); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
  x.set('AB.Leak.gbar',Leak_gbar);
  disp(x.get('AB.Leak.gbar'));
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
variations.IC_plot(gbars,channels,IC,' initial gbar');
%savefig('gbarvar');
