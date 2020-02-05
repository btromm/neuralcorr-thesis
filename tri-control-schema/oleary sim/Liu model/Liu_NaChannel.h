#ifndef _Liu_NA_TRANS_CHANNEL_H_
#define _Liu_NA_TRANS_CHANNEL_H_
#include "IonChannel.h"

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_NaChannel: public IonChannel
{
  public:
    Liu_NaChannel(const double & g_max_in,
                  const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_Na;  // Reversal potential defined in "liuConstants.h"
      p = 3;         // Number of activation gates.
      q = 1;         // Number of inactivation gates.
    }
      
  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return 1 /( 1+exp((cell->getV()+25.5)/-5.29) ); }
    inline double get_act_tau()
      { return 1.32 - (1.26/(1+exp((cell->getV()+120)/-25))); }
    inline double get_inact_inf()
      { return 1 /( 1+exp((cell->getV()+48.9)/5.18) ); }
    inline double get_inact_tau()
      { return (0.67/( 1+exp((cell->getV()+62.9)/-10)) )  * 
               (1.5 + 1/( 1+exp((cell->getV()+34.9)/3.6)) ); }
};

#endif
