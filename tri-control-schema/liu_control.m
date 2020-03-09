% Recapitulating Liu et al., 1998
clear all;

initial_condition_noise = .01;


x = xolotl.examples.BurstingNeuron('prefix','liu');
x.AB.add('LiuSensor');

x.dt = 100;

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

x.set('*gbar',initial_condition_noise*rand(8,1));
x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
channels = x.AB.find('conductance');

data = x.integrate;

%{
figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
time = x.dt*(1:length(data.AB.V))*1e-3;
for i = 1:length(channels)
  if strcmp(channels{i},'Leak')
    continue
  end
  plot(time,data.AB.(channels{i}).gbar

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1.5)
%}
