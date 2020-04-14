% Figure 2 -- Variation in initial conditions

clear all;

% global parameters

T_measure = 6e3;
T_grow = 20e3;
g0 = 1e-1+1e-1*rand(8,1);
numSim = 500;
initial_condition_noise = .01;

x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');

% measure baseline stats
x.t_end = T_measure;
x.dt = .1;
x.integrate;
x.integrate;

% find calcium target for integral controller
Ca_target = x.AB.Ca_average;

% measure baseline metrics
x.output_type = 1;
data = x.integrate;
metrics0 = xtools.V2metrics(data.AB.V,'sampling_rate',10);

% add controllers
channels = x.AB.find('conductance');
leak_cell = {'Leak'};
for c = 1:length(channels)
  if ~ismember(channels{c},leak_cell)
    x.AB.(channels{c}).add('oleary/IntegralController');
    x.AB.(channels{c}).IntegralController.tau_m = 5e6/x.AB.(channels{c}).gbar;
  end
end

% set Ca target
x.AB.Ca_target = Ca_target;

x.dt = 0.1;
x.output_type = 0;
x.t_end = T_grow;
x.sim_dt = .1;

gbars = NaN(8,numSim);
parfor i = 1:numSim
  disp(i)
  x.set('t_end',T_grow);
  x.set('*gbar',initial_condition_noise*rand(8,1)); %same initial conditions every time
  x.set('*Controller.m',0); %always start m from zero
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
%variations.plot(gbars_reduced, channels, leak_gbar);
%savefig('gbarvar');
