function d = dual_control(i_Ca_channels_)
% DUAL_CONTROL - Dual control homeostasis
%
%   D = DUAL_CONTROL(I_CA_CHANNELS_)
%
%   Plots output of dual control model and correlations between
%   maximal conductances
%
%   ...
%
%   Credit to Srinivas Gorur-Shandilya for contributing xolotl framework


% global parameters
tau_K = 5; % filter timescale for i_Ca
Leak_gbar = .2;
i_Ca_channels = i_Ca_channels_;
channels_cat = strjoin(i_Ca_channels);
target_noise = 0.3;
initial_condition_noise = .01;


T_grow = 1e6;
T_measure = 20e3;



x = xolotl.examples.BurstingNeuron('prefix','prinz');
x.AB.add('Leak','gbar',Leak_gbar);

% measure baseline stats
x.t_end = T_measure;
x.dt = .1;
x.integrate;
x.integrate;

Ca_target = x.AB.Ca_average;

% add the controllers to all channels
channels = x.AB.find('conductance');

for i = 1:length(channels)
	if ismember(channels{i},i_Ca_channels)
		x.AB.(channels{i}).add('ICaController','tau_K',tau_K);
	else
		x.AB.(channels{i}).add('IntegralController');
	end
end





x.output_type = 1;
data = x.integrate;

% measure baseline metrics
metrics0 = xtools.V2metrics(data.AB.V,'sampling_rate',10);



% configure controllers
for i = 1:length(channels)

	try
		x.AB.(channels{i}).ICaController.tau_m = 5e6/x.AB.(channels{i}).gbar;
	catch
		x.AB.(channels{i}).IntegralController.tau_m = 5e6/x.AB.(channels{i}).gbar;
	end

end



% targets
for i = 1:length(i_Ca_channels)
	iCa_target = mean(data.AB.(i_Ca_channels{i}).ICaController(:,2));
	x.AB.(i_Ca_channels{i}).ICaController.target = iCa_target;
end


x.AB.Ca_target = Ca_target;

% disable control on leak
x.AB.Leak.(x.AB.Leak.child).tau_g = Inf;


% reset to zero and integrate

x.set('*gbar',initial_condition_noise*rand(8,1));
x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
x.AB.Leak.gbar = rand*Leak_gbar;


x.t_end = T_grow;
x.dt = 100;
x.output_type = 1;
data = x.integrate;



figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on
L = 'Integral control: ';
time = x.dt*(1:length(data.AB.V))*1e-3;
for i = 1:length(channels)
	if strcmp(channels{i},'Leak')
		continue
	end
	if isfield(data.AB.(channels{i}),'IntegralController')
		plot(time,data.AB.(channels{i}).IntegralController(:,2),'k')
		L = [L ' ' channels{i}];
	elseif isfield(data.AB.(channels{i}),'ICaController')
		plot(time,data.AB.(channels{i}).ICaController(:,3),'r')
	end
end
set(gca,'XScale','log','YScale','log','YTick',[1e-2 1e0 1e2 1e4])
xlabel('Time (s)')
ylabel('g (uS/mm^2)')
title(L)

subplot(2,1,2); hold on
x.dt = .1;
x.t_end = 5e3;
x.output_type = 0;
V = x.integrate;
time = x.dt*(1:length(V))*1e-3;
plot(time,V,'k')
set(gca,'YLim',[-80 50])
ylabel('V_m (mV)')
xlabel('Time (s)')
drawnow

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1.5)

figname_plot = strcat(channels_cat, 'plot');
savefig(figname_plot);

% let's look at the correlations of these channels

N = 120;
all_g = NaN(N,8);


x.t_end = 1e6;
x.sim_dt = .1;
x.dt = .1;
x.output_type = 0;


iCa_target0 = iCa_target;
Ca_target0 = Ca_target;

parfor j = 1:N


	disp(j)

	% reset g, mRNA
	x.set('*gbar',initial_condition_noise*rand(8,1));
	x.set('*Controller.m',initial_condition_noise*rand(length(x.get('*Controller.m')*0+1),1));
	x.set('AB.Leak.gbar', rand*Leak_gbar);


	% mess with the targets a bit
	% iCa_target = iCa_target0*(1+randn*target_noise);
	% x.set('*Controller.target',iCa_target)
	Ca_target = Ca_target0*(1+randn*target_noise);
	x.set('AB.Ca_target',Ca_target);

	x.set('t_end',T_grow);
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


	all_g(j,:) = x.get('*gbar');

end

% remove some outliers
rm_this = all_g(:,8) > 2000;
all_g(rm_this,:) = NaN;

correlations.plot(all_g', channels);
figname_corr = strcat(channels_cat, 'corr');
savefig(figname_corr);
