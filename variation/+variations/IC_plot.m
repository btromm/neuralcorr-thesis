function ph = mRNA_plot(gbars, channels,IC,title)

% plot all the gs to show correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

N = length(channels);

c = lines;
idx = 1;

for i = 1:N-1
	subplot(3,3,i); hold on
	if(i==7)
		scatter(IC(end,:),gbars(end,:));
		ylabel(channels{end});
	else
		scatter(IC(i,:),gbars(i,:));
  	ylabel(channels{i});
	end
  x_cat = strcat(channels{i},' ',title);
	xlabel(x_cat);
end
figlib.pretty('PlotLineWidth',1)
plot_title = strcat('Variation in channels vs. variation in ',title);
sgtitle(plot_title)
