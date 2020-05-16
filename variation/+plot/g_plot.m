function ph = g_plot(g0s,gbars,type,channels,exp)
  channels(7) = [];
  c = lines;
  switch type
  case 1
    for i = 1:7
      mean_bar = nanmean(g0s(i,:));
      bar(i,mean_bar,'FaceColor',c(1,:)); hold on
      xticks(linspace(1,7,7));
      set(gca,'XTickLabel',{'A','CaS','CaT','H','KCa','Kd','NaV'});
      xlabel('Channel conductances');
      ylabel('$\bar{g} ( \mu S/mm^{2})$','Interpreter','Latex')
    end
  case 2
    for i = 1:7
      mean_bar = nanmean(gbars(i,:));
      bar(i,mean_bar,'FaceColor',c(2,:)); hold on
      xticks(linspace(1,7,7));
      set(gca,'XTickLabel',{'A','CaS','CaT','H','KCa','Kd','NaV'});
      %xlabel('Channel conductances');
      ylim([0 1200])
    end
  end
  %ylim([0 ]);
  xlim([0 8]);
  if(strcmp(exp,'g_0'))
    str = 'Variation in initial g';
  elseif(strcmp(exp,'mRNAg0'))
    str = 'Variation in initial g & mRNA'
  else
    str = strcat('Variation in',{' '},exp);
  end
  %sgtitle(str,'FontSize',30,'FontWeight','bold');
  xlabel('Channel conductances');
