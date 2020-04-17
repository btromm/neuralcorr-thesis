
function ph = corr_plot(g0s, gbars, channels)



% remove leak
g0s_noleak = g0s;
g0s_noleak(7,:) = [];
gbars_noleak = gbars;
gbars_noleak(7,:) = [];
%gbars_bad_noleak = gbars_bad;
%gbars_bad_noleak(7,:) = [];
channels(7) = [];
N = length(channels);

%plot initial condition correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

ax = figlib.gridAxes(N);

c = lines;
idx = 1;

for i = 1:N-1
	for j = i+1:N
		idx = idx + 1;
		ph(i,j) = scatter(ax(i,j),g0s_noleak(i,:),g0s_noleak(j,:),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
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
sgtitle('Correlations between g_0')
figlib.pretty('PlotLineWidth',1)

% plot g-> infinity correlations
figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

ax = figlib.gridAxes(N);

c = lines;
idx = 1;

for i = 1:N-1
	for j = i+1:N
		idx = idx + 1;
		ph(i,j) = scatter(ax(i,j),gbars_noleak(i,:),gbars_noleak(j,:),'MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerFaceAlpha',.2);
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
sgtitle('Correlations between g_\infty')
figlib.pretty('PlotLineWidth',1)
