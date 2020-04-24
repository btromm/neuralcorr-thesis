function ph = trace_plot(type,exp,var)
  %TRACE_PLOT This function produces voltage traces
  %   type -- before or after integration
  %   exp -- what variables are independent?


switch type
  case 1
    [V,time] = model.variation_minimal(exp, 1,var);
    ph = uipanel('position',[0.025,4.25/6,0.5,1/6],'BackgroundColor','white','BorderType','none');
  case 2
    [V,time] = model.variation_minimal(exp, 2,var);
    ph = uipanel('position',[0.5,4.25/6,0.5,1/6],'BackgroundColor','white','BorderType','none');
end

fig = figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
plot(time,V,'k');
set(gca,'YLim',[-80 50]);
set(gca,'box','off');
if(type == 1)
  ylabel('V_m (mV)');
end
xlabel('Time (s)');
drawnow

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);

set(get(fig,'Children'),'parent',ph);
close(fig);
