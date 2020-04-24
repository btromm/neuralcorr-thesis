function [V,time] = trace_before(x,exp,g0,mRNA_controller,mRNA,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,Ca_target)
  %TRACE_BEFORE This function returns V and time before model has converged
  %   exp -- what are we varying?

  x.set('*gbar',g0(:,1));
  x.set('*Controller.m',mRNA_controller(:,1));
  for c = 1:length(channels)
    if(~ismember(channels{c},leak_cell))
      x.set(strcat('AB.',string(channels{c}),'.m'),mRNA(c,1));
    end
  end

  switch exp
  case 'tau_m'
    for c = 1:length(channels)
      if ~ismember(channels{c},leak_cell)
        x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_m'),tau_ms(c,1));
      end
    end
  case 'tau_g'
    for c = 1:length(channels)
      if ~ismember(channels{c},leak_cell)
        x.set(strcat('AB.',string(channels{c}),'.IntegralController.tau_g'),tau_gs(c,1));
      end
    end
  case 'Ca_t_a_r_g_e_t'
    x.set('AB.Ca_target',Ca_target(1));
  end

  if strcmp(exp,'Leak')
    x.set('AB.Leak.gbar',Leak_gbar(1));
  else
    x.set('AB.Leak.gbar',Leak_gbar);
  end

  x.dt = 0.1;
  x.t_end = 2.5e3;
  x.output_type = 0;

  V = x.integrate;
  time = x.dt*(1:length(V))*1e-3;
