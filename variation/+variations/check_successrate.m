function [success_rate] = check_successrate(g_proper,numSim)

  ind = find(~isnan(g_proper(1,:)));

  success_rate = (length(ind)/numSim)*100;

  
