% Figure 2 -- Variation in initial conditions

clear all;

% global parameters

T_measure = 6e3;
T_grow = 20e3;
g0 = 1e-1+1e-1*rand(8,1);
numSim = 50;
initial_condition_noise = .01;

leak_gbar = [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1];
gbars = zeros(8,numSim,20);

% for each leak gbar
for i = 1:length(leak_gbar)

  clear x;

  % initialize model
  x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');
  x.AB.Leak.gbar = leak_gbar(i);

  % measure baseline stats
  x.t_end = T_measure;
  x.dt = .1;
  x.integrate;
  x.integrate;

  % find calcium target for integral controller
  Ca_target = x.AB.Ca_average;

  % add controllers
  channels = x.AB.find('conductance');
  for c = 1:length(channels)
    x.AB.(channels{c}).add('oleary/IntegralController');
  end

  % measure baseline metrics
  x.output_type = 1;
  data = x.integrate;
  metrics0 = xtools.V2metrics(data.AB.V,'sampling_rate',10);

  % configure controllers
  for c = 1:length(channels)
      x.AB.(channels{c}).IntegralController.tau_m = 5e6/x.AB.(channels{c}).gbar;
  end

  x.AB.Ca_target = Ca_target;

  %disable control on leak
  x.AB.Leak.(x.AB.Leak.child).tau_g = Inf;

  x.t_end = T_grow;
  x.dt = 0.1;
  x.output_type = 0;
  x.t_end = 1e6;
  x.sim_dt = .1;

  for j = 1:numSim
    disp(j)
    x.set('*gbar',initial_condition_noise*rand(8,1));
    x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
    x.t_end = T_grow;
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

    gbars(:,j,i) = x.get('*gbar');
  end
end

gbars_avg = mean(gbars,2);

rm_this = gbars_avg(:,1,:) > 2000;
gbars_avg(rm_this,:) = NaN;

S = size(gbars_avg);
gbars_reduced = reshape(gbars_avg,S(1)*S(2),S(3));

%variations.plot(gbars_reduced, channels, leak_gbar);
%savefig('gbarvar');
