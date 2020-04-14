
function ph = plot(gbars, channels)

% plot all the gs to show correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

N = length(channels);

c = lines;
idx = 1;

for i = 1:N-1
	subplot(3,3,i); hold on
	if(i==7)
		scatter(gbars(7,:),gbars(8,:));
		ylabel(channels{8});
	else
		scatter(gbars(7,:),gbars(i,:));
		ylabel(channels{i});
	end
		xlabel('Leak');
end
sgtitle('Variation in channels vs. variation in Leak')

hold off;
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
ax = figlib.gridAxes(N);

c = lines;
idx = 1;

for i = 1:N-1
	for j = i+1:N
		idx = idx + 1;
		ph(i,j) = scatter(ax(i,j),gbars(i,:),gbars(j,:),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
		if j < N
			set(ax(i,j),'XColor','w');
		end

		if i > 1
			set(ax(i,j),'YColor','w');
		end

		if j == N
			xlabel(ax(i,j),channels{i});
		end

		if i == 1
			ylabel(ax(i,j),channels{j});
		end

	end
end

figlib.pretty('PlotLineWidth',1)
