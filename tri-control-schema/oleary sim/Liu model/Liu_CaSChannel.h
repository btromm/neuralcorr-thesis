#ifndef _Liu_CA_S_CHANNEL_H_
#define _Liu_CA_S_CHANNEL_H_
#include "IonChannel.h"
#include <cmath>

/*
 * These equations are taken from the Liu et al. (1998) paper on page
 * 2319 (Figure 1).
 */
class Liu_CaSChannel: public IonChannel
{
public:
  Liu_CaSChannel(const double & g_max_in,
                 const double & tauG_in) : IonChannel(g_max_in, tauG_in)
  {
    rev_V = 0;  // Reversal potential dynamically calculated in "update"
    p = 3;      // Number of activation gates.
    q = 1;      // Number of inactivation gates.
  }
      
protected:
  /* Equations for activation and inactivation dynamics */
  inline double get_act_inf()
  { return 1 / ( 1+exp((cell->getV()+33)/-8.1) ); }
  inline double get_act_tau()
  { return 1.4  + (7 / ( exp((cell->getV()+27)/10) 
                       + exp((cell->getV()+70)/-13) )); }
  inline double get_inact_inf()
  { return 1 / ( 1+exp((cell->getV()+60)/6.2) ); }
  inline double get_inact_tau()
  { return 60  +  (150 / ( exp((cell->getV()+55)/9)
                         + exp((cell->getV()+65)/-16) )); }
  
  /* Override "updateChannel" */
  void updateChannel(const double & dt)
    {
      rev_V = calcNernst(cell->getCaConc());
      m = expIntegrate(m,get_act_inf(),get_act_tau(),dt);
      h = expIntegrate(h,get_inact_inf(),get_inact_tau(),dt);
      cell->accumulateCaCurrent(calcCurrent(cell->getV()));
    }
    
private:
  /* Helper functions */
  inline double calcNernst(const double & Ca_internal)
  { return ((R*Temperature)/(2*F))*log(Ca_external/Ca_internal)*1000; }
  inline double calcCurrent(const double & v)
  { return g_max*pow(m,p)*pow(h,q)*(v-rev_V); }
  
};

#endif
