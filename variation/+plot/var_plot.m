function [ph,CVs_g,CVs_v,ponr] = var_plot(gbars,g_proper,var,i,channels,exp)
  %VAR_PLOT Progressively resamples data to compute CVs
  % gbars -- full, unfiltered maximal conductances after integration
  % g_proper -- filtered maximal conductances after integration
  % var -- independent variable in the simulation
  % i -- index of desired channel
  % exp -- name of experiment
  ph = uipanel('position',[0,0,1,1.75/6],'BackgroundColor','white','BorderType','none');

  if ~strcmp(exp,'Leak') && ~strcmp(exp,'Ca_t_a_r_g_e_t')
    v = var(i,:);
  else
    v = var;
  end
  g_wrk = g_proper(i,:);
  g = gbars(i,:);;

  v = sort(v);
  g = sort(g);
  mv = median(v);
  rv = max(v) - min(v);
  mg = median(g);
  rg = max(g) - min(g);

  CVs_v = NaN(100,1);
  CVs_g = NaN(100,1);

  ponr_check = 0;
  for j = 1:100
    gind = find(g < mg + j*rg/200 & g > mg - j*rg/200);
    vind = find(v < mv + j*rv/200 & v > mv - j*rv/200);

    gsample = g(gind);
    vsample = v(vind);

    CVs_g(j) = std(gsample)/mean(gsample);
    CVs_v(j) = std(vsample)/mean(vsample);

    % find point of no return
    g_good = intersect(g_wrk,gsample);
    if(ponr_check == 0)
      if(length(g_good)/length(gsample) < 0.1)
        ponr = j;
        ponr_check = 1;
      end
    end
  end
  fig = figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on

  plot(CVs_v(1:ponr),CVs_g(1:ponr),'LineWidth',1);
  set(gca,'FontSize',18,'LineWidth',1);
  figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);
  xlim([CVs_v(1) CVs_v(ponr)+0.1*CVs_v(ponr)]);
  xline(CVs_v(ponr),'-',{'Convergence','Limit'},'LineWidth',1.5);

  if(strcmp(exp,'g_0'))
    label = 'Variability in initial conditions (CV)';
  else
    label = strcat('Variability in',{' '},exp);
  end
  xlabel(label);

  if(strcmp(channels(i),'ACurrent'))
    labely = 'Variability in g_A';
  elseif strcmp(channels(i),'HCurrent')
    labely = 'Variability in g_H';
  else
    labely = strcat('Variability in g',misc.subscript(channels{i}));
  end
  ylabel(labely);
  set(get(fig,'Children'),'parent',ph);
  close(fig);
