function [x,metrics0,Ca_target0] = initialize(T_grow,T_measure)

x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');

% measure baseline stats
x.t_end = T_measure;
x.dt = .1;
x.integrate;
x.integrate;

% find calcium target for integral controller
Ca_target0 = x.AB.Ca_average;

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
x.AB.Ca_target = Ca_target0;

x.dt = 0.1;
x.output_type = 0;
x.t_end = T_grow;
x.sim_dt = .1;
