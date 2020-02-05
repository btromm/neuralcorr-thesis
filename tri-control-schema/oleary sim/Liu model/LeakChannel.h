#ifndef _LEAK_CHANNEL_H_
#define _LEAK_CHANNEL_H_
#include "IonChannel.h"

/*
 * This is a standard leak channel. It can be used in many different
 * contexts.
 */
class LeakChannel: public IonChannel {
  public:
    LeakChannel(const double & g_max_in,
                const double & tauG_in) : IonChannel(g_max_in, tauG_in)
    {
      rev_V = E_leak;         // Rev. potential defined in "constants.h"
      p = 0;                  // No activation. 
      q = 0;                  // No inactivation.
    }

  protected:
    /* Equations for activation and inactivation dynamics */
    inline double get_act_inf()
      { return -1; } // NO ACTIVATION
    inline double get_act_tau()
      { return -1; } // NO ACTIVATION
    inline double get_inact_inf()
      { return -1; } // NO INACTIVATION
    inline double get_inact_tau()
      { return -1; } // NO INACTIVATION
    
    // Override "updateGates", "getReversalCurrent", "getConductance" 
    /// since there is no inactivation for the delayed rectifier current.
    double getReversalCurrent()
      { return g_max*rev_V; }
    double getConductance()
      {  return g_max;  }
    void updateChannel(const double & dt)
      {  (void) dt; } 

};

#endif
