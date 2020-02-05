#ifndef _Liu_K_CA_CHANNEL_H_
#define _Liu_K_CA_CHANNEL_H_
#include "IonChannel.h"

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_KcaChannel: public IonChannel {
  public:
    Liu_KcaChannel(const double & g_max_in,
                   const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_K;         // Rev. potential defined in "constants.h"
      p = 4;               // 4 activation gates 
      q = 0;               // No inactivation.
    }
    
  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return 1 / (1+exp((cell->getV()+28.3)/-12.6)) *
                 ( cell->getCaConc() / (cell->getCaConc()+3) ); }
    inline double get_act_tau()
      { return 90.3 - 75.1/( 1+exp((cell->getV()+46)/-22.7) ); }
    inline double get_inact_inf()
      { return -1; } // NO INACTIVATION
    inline double get_inact_tau()
      { return -1; } // NO INACTIVATION
    
    // Override "updateGates", "getReversalCurrent", "getConductance" 
    /// since there is no inactivation for the Ca-dependent K current.
    double getReversalCurrent()
      { return g_max*pow(m,p)*rev_V; }
    double getConductance()
      {  return g_max*pow(m,p);  }
    void updateChannel(const double & dt)
      { m = expIntegrate(m,get_act_inf(),get_act_tau(),dt); } 
    
};

#endif
