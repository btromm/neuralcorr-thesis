function ph = CV_plot(g0s,gbars,channels)

% remove leak
g0s_noleak = g0s;
g0s_noleak(7,:) = [];
gbars_noleak = gbars;
gbars_noleak(7,:) = [];

channels(7) = [];
N = length(channels);

g0_cv = (std(g0s,0,2)./mean(g0s,2));
gbars_cv = (nanstd(gbars_noleak,0,2)./nanmean(gbars_noleak,2));

for i = 1:1

  figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
  subplot(2,2,1);
  histogram(g0s_noleak(i,:),20,'DisplayStyle','stairs');
  ax = gca;
  ax.Box = 'off';
  label = strcat('g0',model.subscript(channels{i}));
  xlabel(label);
  title_cat = strcat('CV = ',{' '},num2str(g0_cv(i),3));
  title(title_cat);;

  subplot(2,2,2);
  histogram(gbars_noleak(i,:),20,'DisplayStyle','stairs');
  ax = gca;
  ax.Box = 'off';
  label = strcat('g',model.subscript(channels{i}));
  xlabel(label);
  title_cat = strcat('CV = ',{' '},num2str(gbars_cv(i),3));
  title(title_cat);;

  subplot(2,2,3);
  if(i == N)
    scatter(g0s_noleak(i,:),g0s_noleak(1,:));
    label = strcat('g0',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g0',model.subscript(channels{1}));
    ylabel(y_label);
  else
    scatter(g0s_noleak(i,:),g0s_noleak(i+1,:));
    label = strcat('g0',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g0',model.subscript(channels{i+1}));
    ylabel(y_label);
  end

  subplot(2,2,4);
  if(i == N)
    scatter(gbars_noleak(i,:),gbars_noleak(1,:));
    label = strcat('g',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g',model.subscript(channels{1}));
    ylabel(y_label);
  else
    scatter(gbars_noleak(i,:),gbars_noleak(i+1,:));
    label = strcat('g',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g',model.subscript(channels{i+1}));
    ylabel(y_label);
  end
end
figlib.pretty('PlotLineWidth',1)
