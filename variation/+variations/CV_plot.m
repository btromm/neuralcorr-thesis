function ph = CV_plot(g0s,gbars)

% calculate coefficient of variation

g0_cv = (std(g0s)./mean(g0s)).*100;
gbars_cv = (std(gbars)./mean(gbars)).*100;

figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

scatter(g0_cv,gbars_cv);
xlabel('g_0 CV');
ylabel('g_\infty CV');
figlib.pretty('PlotLineWidth',1)
plot_title = strcat('CV of initial vs. developed maximal conductances');
sgtitle(plot_title)
