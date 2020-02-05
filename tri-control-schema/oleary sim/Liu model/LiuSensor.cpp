#include "LiuSensor.h"
#include "mex.h"

/* CONSTRUCTOR:
 *    --> Initialize the "activation" and "inactivation" gates, based on
 *        the initial level of Ca_current. Also set the "maximal
 *        conductance" and the target level of the sensor.
 */
LiuSensor::LiuSensor(const double & targetLevel_in,
                     const double & G_max_in,
                     const double & tauM_in,
                     const double & tauH_in,
                     const double & Z_M_in,
                     const double & Z_H_in)
{
  targetLevel = targetLevel_in;
  G_max = G_max_in;
  tauM = tauM_in;
  tauH = tauH_in;
  Z_m = Z_M_in;
  Z_h = Z_H_in;
  //mexPrintf("New Sensor:  target G_max  tauM   tauH   Z_m    Z_h\n");
  //mexPrintf("             %3.3f  %3.3f  %3.3f  %3.3f  %3.3f  %3.3f\n",targetLevel,G_max,tauM,tauH,Z_m,Z_h);
}

/* "initialize":
 *    --> public function
 *    Set M and H to steady state, based on the initial level of
 *    Ca_current. Used to minimize the level of transient artifacts at the
 *    beginning of the simulation.
 */
void LiuSensor::initialize(const double & Ca_current)
{
  M = getMinf(Ca_current);
  H = getHinf(Ca_current);
}

/* "setState":
 *    --> public function
 *    Set M and H to specified values. This is useful when re-loading and
 *    continuing a simulation.
 */
void LiuSensor::setState(const double & M_in, const double & H_in)
{
  M = M_in;
  H = H_in;
}

/* "updateSensor":
 *    --> public function
 *    Update the gating variables "dt" milliseconds based on the current
 *    level of Ca_current.
 */
void LiuSensor::updateSensor(const double & Ca_current, const double & dt)
{
  M = expIntegrate(M,getMinf(Ca_current),tauM,dt);
  H = expIntegrate(H,getHinf(Ca_current),tauH,dt);
}
    
/* "getState":
 *    --> public function
 *    Push M and H to the back of the output vector. This method is used
 *    for printing out the state of the system.
 */
void LiuSensor::getState(std::vector <double> & output)
{
  output.push_back(M);
  output.push_back(H);
}
        
/* "expIntegrate":
 *   --> private function
 *   Return the predicted value of a state variable "dt" milliseconds into
 *   the future. Method taken from Dayan and Abbott's "Theoretical
 *   Neuroscience."
 */
double LiuSensor::expIntegrate(const double & curr, const double & inf,
                               const double & tau, const double & dt)
{
  return inf + (curr - inf)*exp(-dt/tau);
}
