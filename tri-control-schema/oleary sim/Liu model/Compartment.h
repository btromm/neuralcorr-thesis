#ifndef _COMPARTMENT_H_
#define _COMPARTMENT_H_
#include <vector>
#include "IonChannel.h"
#include "liuConstants.h"
#include "LiuSensor.h"

class Compartment {

public:
  /* Constructor, Destructor */
  Compartment(const double & V_in, const bool & ADHR_switch); // Constructor.
  ~Compartment(); // Destructor.
  
  /* Methods to help set up the simulation */
  void initializeCa();                             // Initialize Ca_conc.
  void setState(std::vector <double> & state_in);  // Specify the state.
  void pushChannel(IonChannel * const channel_in); // Add an IonChannel.
  void pushSensor(LiuSensor sensor_in,           // Add a LiuSensor.
                  std::vector <double> & regulatoryConnections);         
  
  
  /* Methods that help run the simulation */
  void updateCompartment(const double & dt); // Update the compartment.
  inline void accumulateCaCurrent(const double & I_Ca)
  { Ca_current += I_Ca; } // To determine Ca influx and calculate Ca_conc.
  inline void setInjectedCurrent(const double & I_ext_in)
  { I_ext = I_ext_in; } // Set the injected current into the cell.
  
  /* Accessor Functions */
  void getState(std::vector <double> & output); // Get compartment state.
  inline double getV() { return V; }            // To update IonChannels.
  inline double getCaConc() { return Ca_conc; } // To update IonChannels.

protected:
  /* DATA */
  std::vector <IonChannel*> channels; // Vector of the active IonChannels.
  std::vector <LiuSensor> sensors;    // Vector of active LiuSensors.
  
  /* This matrix maps the "sensors" to the "channels" in order to provide
   * the correct homeostatic regulation scheme. The first dimension has
   * "nConductances" elements. The second dimension has "nSensors"
   * elements. In Liu et al. (1998), this map is given in Table I.
   */
  std::vector < std::vector<double> > regulationMap;
  
  /* Time-dependent variables */
  double V;           // Membrane Potential of the compartment [mV].
  double Ca_current;  // Total amount of Calcium current. 
  double Ca_conc;     // Molar internal concentration of Calcium.
  double I_ext;       // Injected current [nA].
  
  // Switch for ADHR
  bool ADHR_is_ON;
  
  // Function to integrate a time step of "dt" milliseconds.
  double expIntegrate(const double & curr, const double & inf,
                      const double & tau, const double & dt);
};

#endif
