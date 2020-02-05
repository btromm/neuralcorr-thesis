#ifndef _Liu_A_CHANNEL_H_
#define _Liu_A_CHANNEL_H_
#include "IonChannel.h"

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_AChannel: public IonChannel
{
  public:
    Liu_AChannel(const double & g_max_in,
                 const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_K;  // Reversal potential defined in "liuConstants.h"
      p = 3;        // Number of activation gates.
      q = 1;        // Number of inactivation gates.
    }
      
  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return 1 / ( 1+exp((cell->getV()+27.2)/-8.7) ); }
    inline double get_act_tau()
      { return 11.6 - 10.4/( 1+exp((cell->getV()+32.9)/-15.2) ); }
    inline double get_inact_inf()
      { return 1 / ( 1+exp((cell->getV()+56.9)/4.9) ); }
    inline double get_inact_tau()
      { return 38.6 - 29.2/( 1+exp((cell->getV()+38.9)/-26.5) ); }
};

#endif
