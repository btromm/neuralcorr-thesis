function ph = trace_plot(x,data,channels,L)

figure('outerposition',[300 300 900 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(2,1,1); hold on
time = x.dt*(1:length(data.AB.V))*1e-3;
for i = 1:length(channels)
	if strcmp(channels{i},'Leak')
		continue
	end
	plot(time,data.AB.(channels{i}).IntegralController(:,2))
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
