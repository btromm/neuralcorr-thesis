function ph = corr_plot(type,g0s,g_proper,channels,i)
  %CORR_PLOT Plots correlations between g_i and g_i+1
  %   g0s -- initial conditions
  %   g_proper -- filtered maximal conductances after integration
  %   channels -- list of ion channels
  %   i -- index of desired channel

  g0_cv = (std(g0s,0,2)./mean(g0s,2));
  gbars_cv = (nanstd(g_proper,0,2)./nanmean(g_proper,2));

  switch type
  case 1
    ph = uipanel('position',[0.05,1.8/6,0.45,2.2/6],'BackgroundColor','white','BorderType','none')
    %ph = uipanel('position',[0 .5 1 .5]);
    if i == length(channels)
      scatterhist(g0s(i,:),g0s(1,:),'Kernel','on','Parent',ph);
      %scatter(g0s(i,:),g0s(1,:));

      if strcmp(channels(1),'ACurrent')
        labely = 'g0_A';
      elseif strcmp(channels(1),'HCurrent')
        labely = 'g0_H';
      else
        labely = strcat('g0',misc.subscript(channels{1}));
      end
      ylabel(labely);
    else
      scatterhist(g0s(i,:),g0s(i+1,:),'Kernel','on','Parent',ph);
      %scatter(g0s(i,:),g0s(i+1,:));
      labely = strcat('g0',misc.subscript(channels{i+1}));
      ylabel(labely);
    end
    if strcmp(channels(1),'ACurrent')
      labelx = 'g0_A';
    elseif strcmp(channels(1),'HCurrent')
      labelx = 'g0_H';
    else
      labelx = strcat('g0',misc.subscript(channels{i}));
    end
    xlabel(labelx);
    figtitle = strcat('CV =',{' '},num2str(g0_cv(i),3));
    title(figtitle)
    %xlim([0 5]);
    %ylim([0 5]);
    % need to add CVs
  case 2
    ph = uipanel('position',[0.5,1.8/6,0.45,2.2/6],'BackgroundColor','white','BorderType','none')
    if i == length(channels)
      scatterhist(g_proper(i,:),g_proper(1,:),'Kernel','on','Location','SouthEast','Parent',ph);
      %scatter(g_proper(i,:),g_proper(1,:));
      if strcmp(channels(1),'ACurrent')
        labely = 'g_A';
      elseif strcmp(channels(1),'HCurrent')
        labely = 'g_H';
      else
        labely = strcat('g',misc.subscript(channels{1}));
      end
      ylabel(labely);
    else
      scatterhist(g_proper(i,:),g_proper(i+1,:),'Kernel','on','Location','SouthEast','Parent',ph);
      %scatter(g_proper(i,:),g_proper(i+1,:));
      labely = strcat('g',misc.subscript(channels{i+1}));
      ylabel(labely);
    end
    if strcmp(channels(1),'ACurrent')
      labelx = 'g_A';
    elseif strcmp(channels(1),'HCurrent')
      labelx = 'g_H';
    else
      labelx = strcat('g',misc.subscript(channels{i}));
    end
    xlabel(labelx);
    xlim([375 750]);
    xticks([400 565 725]);
    ylim([40 80]);
    figtitle = strcat('CV =',{' '},num2str(gbars_cv(i),3));
    title(figtitle);
    % need to add CVs
  end

  figlib.pretty('PlotLineWidth',1.5,'LineWidth',1.5);
