function ph = working_plot(CVs_v, working,exp)

ph = uipanel('position',[0.6,0,1.75/6,1.75/6],'BackgroundColor','white','BorderType','none');
fig = figure('outerposition',[300 300 1003 1001],'PaperUnits','points','PaperSize',[1003 1001]); hold on
plot(CVs_v, working*100,'LineWidth',1);
if(strcmp(exp,'g_0'))
  label = 'Variability in g_A (CV)';
elseif(strcmp(exp,'mRNAg0'))
  label = 'Variability in g_A & g_A mRNA (CV)';
elseif(strcmp(exp,'mRNA'))
  label = 'Variability in g_A mRNA (CV)';
elseif(strcmp(exp,'Leak'))
  label = 'Variability in g_L_e_a_k (CV)';
else
  label = strcat('Variability in',{' '},exp,{' '}, '(CV)');
end
xlabel(label);
ylabel('% Working Models')
xlim([0 CVs_v(end)]);
ylim([0 100]);

figlib.pretty('PlotLineWidth',1.5,'LineWidth',1);
set(get(fig,'Children'),'parent',ph);
close(fig);
