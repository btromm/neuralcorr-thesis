#ifndef LIU_H_CHANNEL_H
#define LIU_H_CHANNEL_H
#include "IonChannel.h"

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_HChannel: public IonChannel {
  public:
    Liu_HChannel(const double & g_max_in,
                 const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_H;        // Rev. potential defined in "constants.h"
      p = 1;              // 1 activation gate 
      q = 0;              // No inactivation.
    }
    
  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return 1 / ( 1+exp((cell->getV()+70)/6) ); }
    inline double get_act_tau()
      { return 272 + 1499/( 1+exp((cell->getV()+42.2)/-8.73) ); }
    inline double get_inact_inf()
      { return -1; } // NO INACTIVATION
    inline double get_inact_tau()
      { return -1; } // NO INACTIVATION
    
    // Override "updateGates", "getReversalCurrent", "getConductance" 
    /// since there is no inactivation for the h-current.
    double getReversalCurrent()
      { return g_max*pow(m,p)*rev_V; }
    double getConductance()
      {  return g_max*pow(m,p);  }
    void updateChannel(const double & dt)
      { m = expIntegrate(m,get_act_inf(),get_act_tau(),dt); } 
};

#endif
