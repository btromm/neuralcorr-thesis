function channels = gen_channels()
%GEN_CHANNELS generate channels variable, that's it
% used for data analysis

  x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');
  channels = x.AB.find('conductance');
