% Recapitulating Liu et al., 1998
clear all;

x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');
x.AB.add('FastLiuSensor');
x.AB.add('SlowLiuSensor');
x.AB.add('DCLiuSensor');

% add controllers and their coupling values
% tau_g = 5e3 ms
A = [0 0 0 0 0 1 1];
B = [-1 1 1 1 -1 -1 0];
C = [-1 0 0 1 -1 0 0];



% optional step to set targets based on xolotl steady-state targets, rather than presets from Liu et al.

x.t_end = 10e3;
x.integrate;
[V,Ca,M] = x.integrate;
FSD_targets = mean(M);
F = FSD_targets(1);
S = FSD_targets(2);
D = FSD_targets(3);
channels = setdiff(x.AB.find('conductance'),'Leak');
for i = 1:length(channels)
  x.AB.(channels{i}).add('LiuController','A',A(i),'B',1,'C',C(i),'Fbar',F,'Sbar',S,'Dbar',D);
end



% use this one for presets (USE ONE OR THE OTHER)
%{
channels = setdiff(x.AB.find('conductance'),'Leak');
for i = 1:length(channels)
  x.AB.(channels{i}).add('liu/LiuController','A',A(i),'B',B(i),'C',C(i));
end
%}
x.set('*gbar',rand(8,1));

x.t_end = 200e3;
x.dt = 1e-3;
x.integrate;
x.t_end = 5e3;
x.plot;
