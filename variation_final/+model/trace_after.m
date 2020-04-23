function [V,time] = trace_after(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow,T_measure,metrics0)
  %TRACE_AFTER This function returns V and time after model has converged
  %   exp -- what are we varying?
  model_ok = 0;
  i = 1;
  while(model_ok == 0)
    x.set('t_end',T_grow);
    x.dt = 0.1;
    x.output_type = 1;

    x.set('*gbar',g0(:,i));
    x.set('*Controller.m',mRNA_controller(:,i));
    for c = 1:length(channels)
      if(~ismember(channels{c},leak_cell))
        x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,i));
      end
    end

    switch exp
    case 'tau_m'
      for c = 1:length(channels)
        if ~ismember(channels{c},leak_cell)
          x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_m'),tau_ms(c,i));
        end
      end
    case 'tau_g'
      for c = 1:length(channels)
        if ~ismember(channels{c},leak_cell)
          x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_g'),tau_gs(c,i));
        end
      end
    case 'Ca_t_a_r_g_e_t'
      x.set('AB.Ca_target',Ca_target(i));
    end

    if strcmp(exp,'Leak')
      x.set('AB.Leak.gbar',Leak_gbar(i));
    else
      x.set('AB.Leak.gbar',Leak_gbar);
    end

    x.integrate;

    Ca_avg_trace = x.get('*Ca_average');
    Ca_tgt_trace = x.get('*Ca_target');
    gbars = x.get('*gbar');
    x.set('t_end',T_measure);
    data_measure = x.integrate;
    metrics_V = data_measure.AB.V;

    model_ok = metrics.metric_check(gbars,metrics_V,metrics0,Ca_avg_trace,Ca_tgt_trace)
    i = i + 1;
  end

  x.dt = .1;
  x.t_end = 2.5e3;
  x.output_type = 0;
  V = x.integrate;
  time = x.dt*(1:length(V))*1e-3;
