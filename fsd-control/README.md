# Recapitulating Liu et al., 1998
## Tri-control homeostatic schema
2/5/20

The purpose of the present experiment is to recapitulate Liu's model
within the constraints of xolotl.

Model successfully built and configured.
Sadly, it is near impossible to attain in a working state.
Mechanisms of variability is the next step, using this formalism with IntegralControllers, rather than FSD controllers.

Parameters:

* Membrane currents described using Hodgkin-Huxley formalism
   * I_i = g_i x m^(p_i) x h^(q_i) x (V - E_i)
* Currents used are based on Turrigiano et al., 1995
   * Fast Na+ -- I_Na
   * Delayed rectifier K+ -- I_Kd
   * Fast transient & slow Ca2+ -- I_CaT, I_CaS
   * Ca2+ dependent K+ -- I_KCa
   * Fast transient K+ -- I_A
   * Hyperpolarization-activated inward cation -- I_H
   * Passive leakage -- I_L
* Equilibrium points for three mean sensor values F, S, and D
   * F = S = D = 0.1
