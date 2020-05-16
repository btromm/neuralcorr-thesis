function [g0,gbars,g_proper,g_other] = get_gbars(x,exp,g0,mRNA_controller,Leak_gbar,tau_ms,tau_gs,leak_cell,channels,T_grow,T_measure,metrics0,numSim,Ca_target)
  %GET_GBARS This function runs numSim simulations and returns gbars for all of them

  % data storage
  gbars = NaN(8,numSim);
  metrics_V = NaN((T_measure/x.dt),numSim);
  Ca_avg = NaN(1,numSim);
  Ca_tgt = NaN(1,numSim);

  parfor i=1:numSim
    disp(i)
    x.set('t_end',T_grow);
    x.set('*gbar',g0(:,i));
    x.set('*Controller.m',mRNA_controller(:,i));

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

    Ca_avg(i) = x.get('*Ca_average');
    Ca_target(i) = x.get('*Ca_target');
    x.set('t_end',T_measure);
    [V,Ca] = x.integrate;
    metrics_V(:,i) = V;

    gbars(:,i) = x.get('*gbar');
  end

  [g_proper,g_other] = filter.filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim);

  save(strcat('gbars',exp),'gbars');
  save(strcat('g_proper',exp),'g_proper');
  %save(strcat('g_other',exp,'g_other'));
