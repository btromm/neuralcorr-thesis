
function ph = plot(gbars_avg, channels, manipulated)

% plot all the gs to show correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

N = length(channels)-1; %-1 for no leak
%{
ax = figlib.gridAxes(N);

c = lines;
idx = 1;

for i = 1:N-1
	for j = i+1:N
		idx = idx + 1;
		ph(i,j) = scatter(ax(i,j),all_g(i,:),all_g(j,:),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
		if j < N
			set(ax(i,j),'XColor','w')
		end

		if i > 1
			set(ax(i,j),'YColor','w')
		end

		if j == N
			xlabel(ax(i,j),channels{i})
		end

		if i == 1
			ylabel(ax(i,j),channels{j})
		end

	end
end

figlib.pretty('PlotLineWidth',1)
%}
for i = 1:length(channels);

set(gca,'XScale','linear','YScale','log');
figlib.pretty('PlotLineWidth',1);
