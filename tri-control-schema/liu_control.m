% Recapitulating Liu et al., 1998
clear all;

x = xolotl.examples.BurstingNeuron('prefix','liu');
x.AB.add('LiuSensor');

% add controllers and their coupling values
% tau_g = 5e3 ms
x.AB.ACurrent.add('LiuController', 'A',0,'B',-1,'C',-1);
x.AB.CaS.add('LiuController', 'A',0,'B',1,'C',0);
x.AB.CaT.add('LiuController', 'A',0,'B',1,'C',0);
x.AB.HCurrent.add('LiuController','A',0,'B',1,'C',1);
x.AB.KCa.add('LiuController','A',0,'B',-1,'C',-1);
x.AB.Kd.add('LiuController','A',1,'B',-1,'C',0);
x.AB.Leak.add('LiuController','A',0,'B',0,'C',0);
x.AB.NaV.add('LiuController','A',1,'B',0,'C',0);
