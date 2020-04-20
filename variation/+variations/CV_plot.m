function ph = CV_plot(g0s,gbars,channels,fig_title,variation,varname)

% remove leak
g0s(7,:) = [];
gbars(7,:) = [];

channels(7) = [];
N = length(channels);

g0_cv = (std(g0s,0,2)./mean(g0s,2));
gbars_cv = (nanstd(gbars,0,2)./nanmean(gbars,2));
if exist('variation','var')
  variation_cv = (std(variation)./mean(variation));
end

for i = 1:1

  figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
  subplot(2,2,1);
  if ~exist('variation','var')
    histogram(g0s(i,:),20,'DisplayStyle','stairs');
  else
    histogram(variation,20,'DisplayStyle','stairs');
  end
  ax = gca;
  ax.Box = 'off';

  if ~exist('variation','var')
    label = strcat('g0',model.subscript(channels{i}));
    title_cat = strcat('CV = ',{' '},num2str(g0_cv(i),3));
  else
    label = strcat('g',model.subscript(varname));
    title_cat = strcat('CV = ',{' '},num2str(variation_cv,3));
  end
  xlabel(label);
  title(title_cat);;

  subplot(2,2,2);
  histogram(gbars(i,:),20,'DisplayStyle','stairs');
  ax = gca;
  ax.Box = 'off';
  label = strcat('g',model.subscript(channels{i}));
  xlabel(label);
  title_cat = strcat('CV = ',{' '},num2str(gbars_cv(i),3));
  title(title_cat);;

  subplot(2,2,3);
  if(i == N)
    scatter(g0s(i,:),g0s(1,:));
    label = strcat('g0',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g0',model.subscript(channels{1}));
    ylabel(y_label);
  else
    scatter(g0s(i,:),g0s(i+1,:));
    label = strcat('g0',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g0',model.subscript(channels{i+1}));
    ylabel(y_label);
  end

  subplot(2,2,4);
  if(i == N)
    scatter(gbars(i,:),gbars(1,:));
    label = strcat('g',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g',model.subscript(channels{1}));
    ylabel(y_label);
  else
    scatter(gbars(i,:),gbars(i+1,:));
    label = strcat('g',model.subscript(channels{i}));
    xlabel(label);
    y_label = strcat('g',model.subscript(channels{i+1}));
    ylabel(y_label);
  end
end
sgtitle(fig_title);
figlib.pretty('PlotLineWidth',1)
