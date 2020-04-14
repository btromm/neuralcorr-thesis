
function ph = plot(gbars, channels, manipulated)

% plot all the gs to show correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

c = lines;
idx = 1;

for i = 1:length(channels)
	subplot(3,3,i);
	set(gca,'XScale','linear','YScale','log');
	hold on
	for j = 1:length(manipulated)
		hold on
		for k = 1:length(gbars(1,:,1))
			hold on
			scatter(manipulated(j),gbars(i,k,j),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
			hold on
			%ylabel(channels(i));
		end
	end
end

figlib.pretty('PlotLineWidth',1)
