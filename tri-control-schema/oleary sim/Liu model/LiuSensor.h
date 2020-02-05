#ifndef _LIU_SENSOR_H_
#define _LIU_SENSOR_H_
#include <cmath>
#include <vector>

class LiuSensor {
  public:
    /* Constructor, initializing, setting state */
    LiuSensor(const double & targetLevel_in,
              const double & G_max_in,
              const double & tauM_in,
              const double & tauH_in,
              const double & Z_m,
              const double & Z_h);
    void initialize(const double & Ca_current);
    void setState(const double & m_in, const double & h_in);
    inline void setH(const double & h_in) { H = h_in; }
    
    // Method to get the distance between the sensor at its target level.
    double getSensorDifference()
    {  return targetLevel - (G_max*pow(M,2)*H);  }
    
    // Method to update gating variables -- M & H.
    void updateSensor(const double & I_Ca, const double & dt);
    
    // Method to access the state variables -- M & H.
    void getState(std::vector <double> & output);
    
  private:
    /* Data */
    double targetLevel; // Target level of sensor activation.
    double G_max;       // "Maximal conductance"
    double M;           // "Activation gate"
    double H;           // "Inactivation gate"
    double tauM;        // Time constant of activation.
    double tauH;        // Time constant of inactivation.
    double Z_m;
    double Z_h;
    
    /* Helper functions */
    inline double getMinf(const double & I_Ca)
    {  return 1 / (1 + exp(Z_m + I_Ca));  }
    inline double getHinf(const double & I_Ca)
    {  return 1 / (1 + exp(-Z_h - I_Ca));  }
    double expIntegrate(const double & curr, const double & inf,
                        const double & tau, const double & dt);
};

#endif
