% Recapitulating Liu et al., 1998
clc

x = xolotl.examples.neurons.BurstingNeuron('prefix','liu');
x.AB.NaV.E = 50;
x.AB.Leak.E = -20;% add controllers and their coupling values


x.AB.add('FastLiuSensor');
x.AB.add('SlowLiuSensor');
x.AB.add('DCLiuSensor');

% add controllers and their coupling values
% tau_g = 5e3 ms
A = [1 0 0 0 0 1 1];
B = [-1 1 1 1 -1 -1 0];
C = [-1 0 0 1 -1 0 0];



% optional step to set targets based on xolotl steady-state targets, rather than presets from Liu et al.
%{
x.t_end = 10e3;
x.integrate;
[V,Ca,M] = x.integrate;
FSD_targets = mean(M);
F = FSD_targets(1);
S = FSD_targets(2);
D = FSD_targets(3);
channels = setdiff(x.AB.find('conductance'),'Leak');
for i = 1:length(channels)
  x.AB.(channels{i}).add('LiuController','A',A(i),'B',B(i),'C',C(i),'Fbar',F,'Sbar',S,'Dbar',D);
end
%}


% use this one for presets (USE ONE OR THE OTHER)
% combinations; F/S (D always 0.1): 0.25/0.09,0.2/0.09,0.06/0.09,0.15/0.045,0.2/0.045,0.06/0.045

F = 0.25;
S = 0.09;
D = 0.1;

channels = setdiff(x.AB.find('conductance'),'Leak');
for i = 1:length(channels)
  x.AB.(channels{i}).add('LiuController','A',A(i),'B',B(i),'C',C(i), 'Fbar', F, 'Sbar', S, 'Dbar', D);
end

g0 = 1e-1+1e-1*rand(8,1);
x.set('*gbar',g0);

x.t_end = 1000e3;
x.integrate;
x.t_end = 5e3;
x.plot;
