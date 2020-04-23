function [g_proper,g_other] = filter_gbars(gbars,metrics_V,metrics0,Ca_avg,Ca_tgt,numSim)

g_proper = NaN(size(gbars));
g_other = NaN(size(gbars));

for i = 1:numSim
  % check that it has converged, and that the bursts are OK
  if abs(Ca_tgt(i) - Ca_avg(i))/Ca_tgt(i) > .1
    disp(i)
    disp('Model did not converge')
    g_other(:,i) = gbars(:,i);
    continue
  end

  metrics = xtools.V2metrics(metrics_V(:,i),'sampling_rate',10);

  if (metrics0.burst_period - metrics.burst_period)/metrics0.burst_period > .2
    disp(i)
    disp('Burst periods not OK')
    g_other(:,i) = gbars(:,i);
    continue
  end

  if (metrics0.duty_cycle_mean - metrics.duty_cycle_mean)/metrics0.duty_cycle_mean > .1
    disp(i)
    disp('Duty cycle not OK')
    g_other(:,i) = gbars(:,i);
    continue
  end
  % if it makes it through, then add to proper
  g_proper(:,i) = gbars(:,i);
end
