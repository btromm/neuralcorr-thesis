% Figure 9 -- prove FSD integral controller model works

clear all;
clc;

%% set global parameters
T_measure = 6e3;
T_grow = 200e3;
numSim = 500;
initial_condition_noise = 0.2;
Leak_gbar = 0.05;
%g0 = 1e-1+1e-1*rand(8,1);

%% initialize model
x = xolotl.examples.neurons.BurstingNeuron('prefix','prinz');

%% add sensors to pull targets from
x.AB.add('FastSensor');
x.AB.add('SlowSensor');
x.AB.add('DCSensor');

%% pull targets & measure baseline metrics
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
leak_cell = {'Leak'};
for c = 1:length(channels)
  if ~ismember(channels{c},leak_cell)
    disp(c)
    x.AB.(channels{c}).add('liu/IntegralController','A',A(c),'B',B(c),'C',C(c),'FTarget',F,'STarget',S,'DTarget',D);
  end
end

x.t_end = 200e3;
x.sim_dt = .1;
tic;
x.integrate;
t = toc;
x.t_end/t/1e3

%% do the simulations!

%{
x.set('*gbar',initial_condition_noise*rand(8,1));
x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
x.AB.Leak.gbar = rand*Leak_gbar;

x.dt = 100;
x.t_end = T_grow;
data = x.integrate;

figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on
time = x.dt*(1:length(data.AB.V))*1e-3;
for i = 1:lenght(channels)
  plot(time,data.AB.(channels{i}).IntegralController(:,2));
  %}
