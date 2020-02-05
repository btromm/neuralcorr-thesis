#ifndef LIU_K_D_CHANNEL_H
#define LIU_K_D_CHANNEL_H
#include "IonChannel.h"

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_KdChannel: public IonChannel {
  public:
    Liu_KdChannel(const double & g_max_in,
                  const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_K;         // Rev. potential defined in "constants.h"
      p = 4;               // 4 activation gates 
      q = 0;               // No inactivation.
    }
    
  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return 1 / ( 1+exp((cell->getV()+12.3)/-11.8) ); }
    inline double get_act_tau()
      { return 7.2 - 6.4/( 1+exp((cell->getV()+28.3)/-19.2) ); }
    inline double get_inact_inf()
      { return -1; } // NO INACTIVATION
    inline double get_inact_tau()
      { return -1; } // NO INACTIVATION
    
    // Override "updateGates", "getReversalCurrent", "getConductance" 
    /// since there is no inactivation for the delayed rectifier current.
    double getReversalCurrent()
      { return g_max*pow(m,p)*rev_V; }
    double getConductance()
      {  return g_max*pow(m,p);  }
    void updateChannel(const double & dt)
      { m = expIntegrate(m,get_act_inf(),get_act_tau(),dt); } 
};

#endif
