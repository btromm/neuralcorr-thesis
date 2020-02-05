#include "Compartment.h"
#include <cmath>
#include "mex.h"

using namespace std;

/* CONSTRUCTOR:
 * Initialize membrane potential
 */
Compartment::Compartment(const double & V_in, const bool & ADHR_switch)
{
  V = V_in;
  Ca_conc = 4;
  ADHR_is_ON = ADHR_switch;
}

/* DESTRUCTOR:
 * Delete all of the dynamically allocated IonChannels in the compartment.
 */
Compartment::~Compartment()
{
  vector<IonChannel*>::iterator chanItr;
  for (chanItr = channels.begin(); chanItr != channels.end(); chanItr++)
    delete (*chanItr);
}

/* "initializeCa":
 *    --> public function
 *    Sets the initial concentration of Calcium ("Ca_conc") to a reasonable
 *    value based on the initial voltage of the cell, and the steady state
 *    I_Ca at that specified voltage. (Note that I_Ca is negatively related
 *    to the value of Ca_conc, due to the Nerst equation. Thus, repeatedly
 *    calling this function at the beginning of the simulation will make
 *    a better starting state).
 */
void Compartment::initializeCa()
{
  Ca_current = 0; // CaCurrent is accumulated by the IonChannel objects in
                  /// the "updateChannel" function.
  
  // Iterate over all IonChannels and get the steady state calcium current.
  vector<IonChannel*>::iterator chanItr;
  for (chanItr = channels.begin(); chanItr != channels.end(); chanItr++) {
    (*chanItr)->updateChannel(0); // Update the gating variables.
  }
  
  // Set Ca_conc to the steady state
  Ca_conc = 0.05 - (0.94*Ca_current);
}


/* "setState":
 *    --> public function
 *    Sets the values of all state variables in this compartment to those
 *    specified in the input vector "state_in". The gating variables for
 *    all ion channels are set by the function "setState" in the IonChannel
 *    class. The parameter "state_in" must follow the same format as the
 *    the output of "getState" (i.e. IonChannels must be in the correct
 *    order) -- see the function "getState", below.
 */
void Compartment::setState(std::vector <double> & state_in)
{
  V = state_in[0];
  Ca_conc = state_in[1];
  
  // Iterate over all IonChannels, and set the state of each.
  vector<IonChannel*>::iterator chanItr;
  int i = 2;
  for (chanItr = channels.begin(); chanItr != channels.end(); chanItr++) {
    (*chanItr)->setState(state_in[i],state_in[i+1],state_in[i+2]);
    i += 3;
  }
  // Iterate over all Sensors and have them spit out thier info
  vector<LiuSensor>::iterator sensItr;
  for (sensItr = sensors.begin(); sensItr != sensors.end(); sensItr++) {
    sensItr->setState(state_in[i],state_in[i+1]);
    i+=2;
  }
}

/* "updateCompartment":
 *    --> public function
 *    Updates the membrane potential ("V") of the compartment as well as
 *    the gating variables for all IonChannel objects in the compartment.
 */
void Compartment::updateCompartment(const double & dt)
{
  // Quantities summed over all ion channels. Used to calculate the steady
  /// state voltage, membrane time constant, and steady state [Ca++].
  double totalReversalCurrent = 0;
  double totalConductance = 0;
  Ca_current = 0; // CaCurrent is accumulated by the IonChannel objects in
                  /// the "updateChannel" function.
  
  // Iterate over all IonChannels
  vector<IonChannel*>::iterator chanItr;
  for (chanItr = channels.begin(); chanItr != channels.end(); chanItr++) {
    (*chanItr)->updateChannel(dt); // Update the gating variables.
    totalReversalCurrent += (*chanItr)->getReversalCurrent();
    totalConductance += (*chanItr)->getConductance();
  }
  // Iterate over all Sensors, passing them the Ca_current
  vector<LiuSensor>::iterator sensItr;
  for (sensItr = sensors.begin(); sensItr != sensors.end(); sensItr++) {
    sensItr->updateSensor(Ca_current,dt);
  }
  (sensors.back()).setH(1);
  
  
  // Steady-state voltage (V_inf) and membrane time constant (tau_V). The
  /// variable "c_density is specified in "constants.hpp" and is the 
  /// capacitance per unit area of the compartment in [uF/cm^2]. Equations
  /// from Dayan and Abbott's "Theoretical Neuroscience".
  double V_inf = (totalReversalCurrent + I_ext) / totalConductance;
  double tau_V = c_density / totalConductance;
  
  // Calcium steady state, as calculated in Liu et al. (1998)
  double Ca_inf = 0.05 - (0.94*Ca_current);
  
  // Integrate the voltage and internal calcium of the compartment
  V = expIntegrate(V,V_inf,tau_V,dt);
  Ca_conc = expIntegrate(Ca_conc,Ca_inf,20,dt); // 20 msec time constant.
  
  // ADHR regulation of maximal conductances.
  if( ADHR_is_ON ) {
    size_t i = 0;
    for( chanItr = channels.begin(); chanItr != channels.end(); chanItr++) {
      double dGdT = 0; // The change in conductance for this channel.
      for( size_t j=0; j<sensors.size(); j++) {
        dGdT += regulationMap[j][i] * sensors[j].getSensorDifference();
      }
      (*chanItr)->regulateMaxG(dGdT,dt);
      i++;
    }
  }
}

/* "pushChannel":
 *   --> public function
 *   Given a pointer to an IonChannel, this function pushes that IonChannel
 *   to the back of the vector "channels". Effectively, this adds a new
 *   current to the compartment.
 */
void Compartment::pushChannel(IonChannel * const channel_in)
{
  channel_in->initialize(this);
  channels.push_back(channel_in);
}

/* "pushSensor":
 *   --> public function
 *   Given a new LiuSensor, this function pushes that LiuSensor to the back
 *   of the vector "sensors". Additionally, it incorporates the vector 
 *   "regulatoryConnections" into the "regulationMap" matrix (which maps
 *   the activity of the sensors to regulatory changes in the maximal
 *   conductances).
 */
void Compartment::pushSensor(LiuSensor sensor_in,
                             std::vector <double> & regulatoryConnections)
{
  sensor_in.initialize(Ca_current);
  sensors.push_back(sensor_in);
  
  regulationMap.push_back(regulatoryConnections);
}

/* "getState":
 *   --> public function
 *   Given a reference to the output vector, fill that vector up with the
 *   current state of the system.
 */
void Compartment::getState(vector <double> & output)
{
  output.push_back(V);
  output.push_back(Ca_conc);
  
  // Iterate over all IonChannels. And have those channels spit out their
  // activation and inactivation variables.
  vector<IonChannel*>::iterator chanItr;
  for (chanItr = channels.begin(); chanItr != channels.end(); chanItr++) {
    (*chanItr)->getState(output);
  }
  // Iterate over all Sensors and have them spit out thier info
  vector<LiuSensor>::iterator sensItr;
  for (sensItr = sensors.begin(); sensItr != sensors.end(); sensItr++) {
    sensItr->getState(output);
  }
}

/* "expIntegrate":
 *    --> protected function
 *    Calculates the integration step (used in "updateCompartment"). The
 *    integration method is taken from Dayan and Abbott's "Theoretical
 *    Neuroscience".
 */ 
double Compartment::expIntegrate(const double & curr, const double & inf,
                                 const double & tau, const double & dt)
{     return inf + (curr - inf)*exp(-dt/tau);      }
