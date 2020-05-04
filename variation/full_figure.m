function [fig1,fig2] = full_figure(g0s,gbars,g_proper,var)
  %% This function produces full figures for each experiment

  exp = 'tau_m'; % choose your fighter!

  % remove leak
  g0s(7,:) = [];
  g_proper(7,:) = [];

  channels = model.gen_channels;
  channels(7) = [];
  N = length(channels);

  fig1 = figure('outerposition',[300 300 1300 1001],'PaperUnits','points','PaperSize',[1300 1001]);
  set(gca,'XColor',[1 1 1],'YColor',[1 1 1]);
  %title('Variation in initial conditions');

  u1 = plot.trace_plot(1,exp,var);
  u2 = plot.trace_plot(2,exp,var);
  u5 = plot.var_plot(gbars,g_proper,var,1,channels,exp);
  u3 = plot.corr_plot(1,g0s,g_proper,channels,1);
  u4 = plot.corr_plot(2,g0s,g_proper,channels,1);

  fig2 = figure('outerposition',[300 300 1300 600],'PaperUnits','points','PaperSize',[1300 600]);
  subplot(1,2,1);
  plot.g_plot(g0s,gbars,1,channels,exp);
  subplot(1,2,2);
  plot.g_plot(g0s,gbars,2,channels,exp);
