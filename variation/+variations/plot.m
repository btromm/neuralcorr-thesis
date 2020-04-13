
function ph = plot(gbars, channels, manipulated)

% plot all the gs to show correlations
figure('outerposition',[300 300 1401 601],'PaperUnits','points','PaperSize',[1401 601]); hold on

N = length(channels); %-1 for no leak

c = lines;
idx = 1;

for i = 1:N
	plot(manipulated', gbars(i,:), '-o');
end
xlabel('Gbar leak');
ylabel('Gbars');
legend(channels);

set(gca,'XScale','linear','YScale','log','XTick', manipulated(1:2:end));
figlib.pretty('PlotLineWidth',1);
