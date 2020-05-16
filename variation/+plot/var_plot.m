function [ph,CVs_g,CVs_v,ponr] = var_plot(gbars,g_proper,var,i,channels,exp)
  %VAR_PLOT Progressively resamples data to compute CVs
  % gbars -- full, unfiltered maximal conductances after integration
  % g_proper -- filtered maximal conductances after integration
  % var -- independent variable in the simulation
  % i -- index of desired channel
  % exp -- name of experiment
  ph = uipanel('position',[0.115,0,1.75/6,1.75/6],'BackgroundColor','white','BorderType','none');

  if ~strcmp(exp,'Leak') && ~strcmp(exp,'Ca_t_a_r_g_e_t')
    v = var(i,:);
  else
    v = var;
  end
  g_wrk = g_proper(i,:);
  g = gbars(i,:);;
  v = sort(v);
  g = sort(g);

  index = 1;
  x = [];
  z = [];
  while(index < length(g))
    if(length(intersect(g(index),g_wrk)) > 0)
      if(isempty(x))
        x(1) = index;
      else
        x(end+1) = index;
      end
      index = index+1;
    else
      index = index+1;
      if(~isempty(x) & length(z) < length(x))
        z = x;
      end
      x = [];
    end
  end
  if(isempty(x))
    zv = v(z);
    z = g(z);
    mg = median(z);
    mv = median(zv);
  else
    xv = v(x);
    x = g(x);
    mg = median(x);
    mv = median(xv);
  end

  rv = max(v) - min(v);
  rg = max(g) - min(g);

  CVs_v = NaN(100,1);
  CVs_g = NaN(100,1);
  working = NaN(100,1);

  ponr_check = 0;
  for j = 1:100
    gind = find(g < mg + j*rg/100 & g > mg - j*rg/100);
    vind = find(v < mv + j*rv/100 & v > mv - j*rv/100);

    gsample = g(gind);
    vsample = v(vind);

    CVs_g(j) = nanstd(gsample)/nanmean(gsample);
    CVs_v(j) = nanstd(vsample)/nanmean(vsample);

     %find point of no return
    g_good = intersect(g_wrk,gsample);
    working(j) = length(g_good)/length(gsample);
    if(ponr_check == 0)
    if(working(j) < 0.5)
        ponr = j;
        ponr_check = 1;
      end
    end
  end
  CVs_v = sort(CVs_v);
  CVs_g = sort(CVs_g);
  fig = figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
  if(ponr_check == 0)
    plot(CVs_v,CVs_g,'LineWidth',1); hold on
    plot(CVs_v,CVs_v,'--k');
    %yticks([0 CVs_v/2 max(CVs_v)]);
  else
    if(strcmp(channels(i),'ACurrent'))
      labely = 'Variability in g_A';
    elseif strcmp(channels(i),'HCurrent')
      labely = 'Variability in g_H';
    else
      labely = strcat('Variability in g',misc.subscript(channels{i}));
    end
    ylabel(labely);
    plot(CVs_v(1:ponr),CVs_g(1:ponr),'LineWidth',1); hold on
    plot(CVs_v(1:ponr),CVs_v(1:ponr),'--k');
    xline(CVs_v(ponr),'-','LineWidth',1.5,'FontSize',15);
    xlim([0 CVs_v(ponr)+0.1*CVs_v(ponr)]);
  end
  if(strcmp(channels(i),'ACurrent'))
    labely = 'Variability in g_A';
  elseif strcmp(channels(i),'HCurrent')
    labely = 'Variability in g_H';
  else
    labely = strcat('Variability in g',misc.subscript(channels{i}));
  end
  ylabel(labely);
  set(gca,'FontSize',18,'LineWidth',1);
  figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);

  if(strcmp(exp,'g_0'))
    labelx = 'Variability in g_A (CV)';
  elseif(strcmp(exp,'mRNAg0'))
    labelx = 'Variability in g_A & g_A mRNA (CV)';
  elseif(strcmp(exp,'mRNA'))
    labelx = 'Variability in g_A mRNA (CV)'
  elseif(strcmp(exp,'Leak'))
    labelx = 'Variability in g_L_e_a_k (CV)';
  else
    labelx = strcat('Variability in',{' '},exp,{' '},'(CV)');
  end
  xlabel(labelx);

  ylim_curr = get(gca,'ylim');
  ylim_curr(1) = 0;
  set(gca,'ylim',ylim_curr)
  %ylim([0 max(CVs_g)*40])
  %ax = gca;
%  ax.YAxis(2).Visible = 'off';
  %ax.YAxis(2).Color = 'k';
  %ax.YAxis(1).Color = 'k';
  set(get(fig,'Children'),'parent',ph);
  close(fig);

  plot.working_plot(CVs_v,working,exp)
