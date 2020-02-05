function gVec = loadConductances(conductance_set_identifier)

if conductance_set_identifier > 6
  disp(conductance_set_identifier)
  error('conductance_set_identifier out of range')
end

switch conductance_set_identifier

    case 1 % Randomize all conductances to final distribution of jon's runs
      g_bar_Na  = randUnif(17.21,145.9);
      g_bar_CaT = randUnif(0.4083,2.864);
      g_bar_CaS = randUnif(0.0573,5.412);
      g_bar_A   = randUnif(0.8623,134.9);
      g_bar_KCa = randUnif(2.061,134.0);
      g_bar_Kd  = randUnif(0.2747,68.96);
      g_bar_H   = randUnif(0.0153,0.7641);
      g_leak    = 0.01;
    case 2 % Randomize all conductances to initial condition of jon's runs
      g_bar_Na  = randUnif(2.5,47.5);
      g_bar_CaT = randUnif(0.05,0.95);
      g_bar_CaS = randUnif(0.05,0.95);
      g_bar_A   = randUnif(2.5,47.5);
      g_bar_KCa = randUnif(2.5,47.5);
      g_bar_Kd  = randUnif(2.5,47.5);
      g_bar_H   = randUnif(0.05,0.95);
      g_leak    = 0.01;
    case 3 % Evolves to burster, line A in Liu et al. Figure 3
      g_bar_Na  = 33;
      g_bar_CaT = 0.24;
      g_bar_CaS = 0.78;
      g_bar_A   = 24;
      g_bar_KCa = 37;
      g_bar_Kd  = 15;
      g_bar_H   = 0.1;
      g_leak    = 0.01;
    case 4 % Evolves to burster, line B in Liu et al. Figure 3
      g_bar_Na  = 24;
      g_bar_CaT = 0.81;
      g_bar_CaS = 1.1;
      g_bar_A   = 38;
      g_bar_KCa = 20;
      g_bar_Kd  = 41;
      g_bar_H   = 0.1;
      g_leak    = 0.01;
    case 5
      % This is a model in which the conductance evolve in a large limit
      % cycle. The behavior over a course of 24 hours is shown in notebook
      % #1 on page 54. Note, however, that the large calcium conductances
      % may be the only reason that this happens.
      g_bar_Na  = 12419.2041859291;
      g_bar_CaT = 53.4751806553428;
      g_bar_CaS = 7.73796728981213;
      g_bar_A   = 438.657496180167;
      g_bar_KCa = 131.012641761829;
      g_bar_Kd  = 273.662225950864;
      g_bar_H   = 0.192681868888274;
      g_leak    = 0.01;
      
end

gVec = [g_bar_Na;
        g_bar_CaT;
        g_bar_CaS;
        g_bar_A;
        g_bar_KCa;
        g_bar_Kd;
        g_bar_H;
        g_leak];
    
function rand_num = randUnif(minimum,maximum)
  rand_num = minimum + (maximum-minimum)*rand;