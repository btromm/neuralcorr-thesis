function [CVs_g,CVs_v,ponr] = full_figure(g0s,gbars,g_proper,g_other,var)
  %% This function produces full figures for each experiment
  % Could be made into a main script which pulls gbars before plotting pub. figures, but not necessary as I already have the data.
  % Will turn this into a main script once my thesis is written, so others can reproduce my work more easily :)

  exp = 'g_0'; % choose your fighter!

  % remove leak
  g0s(7,:) = [];
  g_proper(7,:) = [];
  g_other(7,:) = [];

  model.gen_channels;
  channels(7) = [];
  N = length(channels);

  h6 = figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
  set(gca,'XColor',[1 1 1],'YColor',[1 1 1]);
  title('Variation in initial conditions');

  u1 = plot.trace_plot(1,exp);
  u2 = plot.trace_plot(2,exp);
  u3 = plot.corr_plot(1,g0s,g_proper,channels,1);
  u4 = plot.corr_plot(2,g0s,g_proper,channels,1);
  [u5,CVs_g,CVs_v,ponr] = plot.var_plot(gbars,g_proper,var,1,channels,exp);



  figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);
