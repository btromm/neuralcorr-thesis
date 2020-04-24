function ph = g_plot(g0s,gbars,type,channels,exp)
  channels(7) = [];
  switch type
  case 1
    for i = 1:7
      mean_bar = mean(g0s(i,:));
      bar(i,mean_bar,'FaceColor',[0 0.4470 0.7410]); hold on
      xticks(linspace(1,7,7));
      set(gca,'XTickLabel',{'A','CaS','CaT','H','KCa','Kd','NaV'});
      xlabel('Initial conditions (nS)');
      ylabel('Conductance (nS)');
      xlim([0 8]);
      ylim([0 0.2]);
    end
  case 2
    for i = 1:7
      mean_bar = mean(gbars(i,:));
      bar(i,mean_bar,'FaceColor',[0 0.4470 0.7410]); hold on
      xticks(linspace(1,7,7));
      set(gca,'XTickLabel',{'A','CaS','CaT','H','KCa','Kd','NaV'},'YScale','log');
      xlabel('Maximal conductances (nS)');
      xlim([0 8]);
    end
  end
  if(strcmp(exp,'g_0'))
    str = 'Variation in initial conditions';
  else
    str = strcat('Variation in',{' '},exp);
  end
  sgtitle(str,'FontSize',18);
  figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);
