function [x,metrics0,channels,FTarget,STarget,DTarget,tau_ms,tau_gs] = initialize(T_grow,T_measure,type,numSim)

  x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');

  % add sensors to pull targets from
  x.AB.add('FastSensor');
  x.AB.add('SlowSensor');
  x.AB.add('DCSensor');

  % pull targets & measure baseline metrics
  x.t_end = T_measure;
  x.dt = 0.1;
  x.integrate;
  [V,Ca,M] = x.integrate;

  FSD_targets = mean(M);
  F = FSD_targets(1);
  S = FSD_targets(2);
  D = FSD_targets(3);

  x.output_type = 1;
  data = x.integrate;
  metrics0 = xtools.V2metrics(data.AB.V,'sampling_rate',10);

  %% add controller, set targets
  % coupling values
  A = [1 0 0 0 0 1 0 1];
  B = [-1 1 1 1 -1 -1 0 0];
  C = [-1 0 0 1 -1 0 0 0];

  channels = x.AB.find('conductance');
  leak_cell = {'Leak'}

  switch type
    case 1
      for c = 1:length(channels)
        if ~ismember(channels{c},leakcell)
          x.AB.(channels{c}).add('src/IntegralController');
        end
