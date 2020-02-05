#ifndef _ION_CHANNEL_HPP_
#define _ION_CHANNEL_HPP_
#include <vector>
#include "liuConstants.h"
#include "mex.h"

// Must declare Compartment as a class to establish reciprocal pointers
class Compartment; 

class IonChannel {
  public:
    /* Constructor, initializing, setting state */
    IonChannel(const double & g_max_in, const double & tauG_in);
    void initialize(Compartment * cell_in);
    void setState(const double & g_max_in,
                  const double & m_in,
                  const double & h_in);
    
    /* Accessor Methods */
    virtual double getReversalCurrent(); // V_rev*g; in [mV]
    virtual double getConductance();     // Conductance in [mS/cm^2]
    inline double getMaxG() { return g_max; } // [mS/cm^2]
    void getState(std::vector <double> & output); // Get state variables.
    
    /* Running the Simulation */
    virtual void updateChannel(const double & dt); // Update m & h.
    inline void regulateMaxG(const double & dGdT, const double & dt)
    {  g_max += ((dGdT*g_max)/tauG)*dt; }  // ADHR tuning of g_max. mexPrintf("//  dGdT = %2.5f  //",dGdT);
    
  protected:
    // Functions to be specified by the sub-class. Namely, the activation
    /// and inactivation kinetics.
    virtual inline double get_act_inf() = 0;
    virtual inline double get_act_tau() = 0;
    virtual inline double get_inact_inf() = 0;
    virtual inline double get_inact_tau() = 0;
        
    /* Data */
    Compartment * cell; // Pointer to the Compartment.
    double g_max; // Maximal conductance [mS cm^-2].
    double rev_V; // Reversal Potential (can be changed by "setRev")[mV].
    double m;     // Activation variable (between 0 and 1)
    double h;     // Inactivation variable (between 0 and 1)
    int p;        // Number of activation gates (cannot be changed).
    int q;        // Number of inactivation gates (cannot be changed).
    double tauG;  // Time constant that determines rate of ADHR.
        
    /* Helper functions */
    double expIntegrate(const double & curr, const double & inf,
                        const double & tau, const double & dt);
};

// Once the IonChannel class is defined, then include "Compartment.h"
#include "Compartment.h"

#endif
