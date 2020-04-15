function ph = mRNA_plot(gbars, channels,Ca_target,title)

% plot all the gs to show correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

N = length(channels);

c = lines;
idx = 1;

for i = 1:N
	subplot(3,3,i); hold on
  scatter(Ca_target(:),gbars(i,:));
  ylabel(channels{i});
	xlabel(title);
end
figlib.pretty('PlotLineWidth',1)
plot_title = strcat('Variation in channels vs. variation in ',title);
sgtitle(plot_title)
