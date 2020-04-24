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
    ph = uipanel('position',[0.0,1.8/6,0.45,2.2/6],'BackGroundColor','white','BorderType','none');
    h = scatterhist(g0s(i,:),g0s(i+1,:),'Kernel','on','Parent',ph,'Direction','out');
    labely = strcat('g0',misc.subscript(channels{i+1}));
    ylabel(labely);
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

  case 2
    ph = uipanel('position',[0.55,1.8/6,0.45,2.2/6],'BackGroundColor','white','BorderType','none');
    ph2 = uipanel('position',[0.415,2.93/6,0.17,0.5/6],'BackGroundColor','white','BorderType','none');
    annotation(ph2,'arrow',[0 1],[0.5 0.5],'LineWidth',1.5,'HeadWidth',15);
    h = scatterhist(g_proper(i,:),g_proper(i+1,:),'Kernel','on','Parent',ph,'Direction','out','Location','SouthEast');
    xlim([min(g_proper(i,:))-200 max(g_proper(i,:))+200]);
    ylim([min(g_proper(i+1,:))-50 max(g_proper(i+1,:))+50]);
    g_temp = find(~isnan(g_proper(i,:)));
    g_proper1 = g_proper(i,g_temp);
    g_temp = find(~isnan(g_proper(i+1,:)));
    g_proper2 = g_proper(i+1,g_temp);
    [P,S] = polyfit(g_proper1,g_proper2,1);
    rsquared = 1 - (S.normr/norm(g_proper2 - mean(g_proper2)))^2;
    str = strcat('m =',{' '},num2str(P(1),3),{'\newline'},'R^2 =',{' '},num2str(rsquared,3))
    annotation(ph,'textbox',[0.45 0.575 0.3,0.3],'EdgeColor',[1 1 1],'String',str,'FitBoxToText','on','FontSize',10);

    % = TextLocation(str,'Location','northeast');
    %gtext(str);
    labely = strcat('g',misc.subscript(channels{i+1}));
    ylabel(labely);
    if strcmp(channels(1),'ACurrent')
      labelx = 'g_A';
    elseif strcmp(channels(1),'HCurrent')
      labelx = 'g_H';
    else
      labelx = strcat('g',misc.subscript(channels{i}));
    end
    xlabel(labelx);
    figtitle = strcat('CV =',{' '},num2str(gbars_cv(i),3));
    title(figtitle);
    figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);
    for j = 1:3
      if(strcmp(h(j).Tag,'xhist') || strcmp(h(j).Tag,'yhist'))
        set(h(j),'XLimMode','auto');
      end
    end
  end
