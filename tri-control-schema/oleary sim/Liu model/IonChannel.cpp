#include "IonChannel.h"
#include <cmath>
#include "mex.h"


/* CONSTRUCTOR:
 *    --> Set the maximal conductance of the channel, and set the time
 *        constant for changes in the maximal conductance due to ADHR.
 */
IonChannel::IonChannel(const double & g_max_in, const double & tauG_in)
{
  g_max = g_max_in;
  tauG = tauG_in;
}

/* "initialize":
 *    --> public
 *    Establish the pointer to the Compartment object. Also, set the
 *    activation and inactivation gates to their steady state values. This
 *    function is called after a new IonChannel is constructed. (Pure
 *    virtual functions don't seem to work in the constructor.)
 */
void IonChannel::initialize(Compartment * cell_in)
{
  cell = cell_in;      // Initial membrane potential [mV].
  m = get_act_inf();   // Initialize m to steady state.
  h = get_inact_inf(); // Initialize h to steady state.
}

/* "setState":
 *    --> public
 *    Set the activation and inactivation gates to specified values. This
 *    is need to load and continue a previous simulation. Also sets the
 *    maximal conductance, since this can change with ADHR
 */
void IonChannel::setState(const double & g_max_in,
                          const double & m_in,
                          const double & h_in)
{
  g_max = g_max_in;  // Initialize g_max to first value.
  m = m_in;          // Initialize m to second value.
  h = h_in;          // Initialize h to third value.
}

/* "getReversalCurrent" and "getConductance":
 *   --> public
 *   These two methods return the two things that "Compartment.cpp" needs
 *   to time integrate its membrane potential. "getReversalCurrent" returns
 *   the conductance multiplied byu the reversal potential of the ion
 *   (rev_V*g). "getConductance" returns the conductance of the ion
 *   current (g). These functions are virtual, because they should be
 *   overriden for cases where there is no inactivation gate.
 */
double IonChannel::getReversalCurrent()
      { return g_max*pow(m,p)*pow(h,q)*rev_V; }
double IonChannel::getConductance()
      {  return g_max*pow(m,p)*pow(h,q);  }
    
/* "updateGates":
 *   --> public
 *   Function that updates the gating variables by "dt" milliseconds.
 *   This should be overridden in two cases:
 *     1) If the ion channel does not have an inactivation gate. The
 *        function should be overriden so that "h" is not unnecessarily
 *        calculated every time step. (The default function specified below
 *        updates both m and h by the exponential Euleur method).
 *     2) If the reversal potential of the channel is recalculated by the
 *        Nernst equation every time step. This would need to be added to
 *        the function below.
 *     3) If the ion channel passes calcium, and we have a calcium
 *        buffering system, then this function should call the
 *        "accumulateCaCurrent" function to help the Compartment object
 *        update its internal calcium concentration.
 */
void IonChannel::updateChannel(const double & dt)
{
  m = expIntegrate(m,get_act_inf(),get_act_tau(),dt);
  h = expIntegrate(h,get_inact_inf(),get_inact_tau(),dt);
}

/* "getState":
 *   --> public
 *   Output the current state of the IonChannel by pushing the values of
 *   m and h to the back of the vector "output" (which is passed by
 *   reference).
 */
void IonChannel::getState(std::vector <double> & output)
{
  output.push_back(g_max);
  output.push_back(m);
  output.push_back(h);
}

/* "expIntegrate":
 *   --> protected
 *   Return the predicted value of a state variable "dt" milliseconds into
 *   the future. Method taken from Dayan and Abbott's "Theoretical
 *   Neuroscience."
 */
double IonChannel::expIntegrate(const double & curr, const double & inf,
                                const double & tau, const double & dt)
{
  return inf + (curr - inf)*exp(-dt/tau);
}
