// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// FSD Sensor
// this mechanism averages the Calcium current
// in the compartment it is in
// over three different time scales,
// corresponding to the Fast, Slow, and DC sensors
// as per Liu et al., 1998
// useful to measure Calcium current, and
// also useful in other mechanisms

#ifndef DCLIUSENSOR
#define DCLIUSENSOR
#include "mechanism.hpp"
#include <limits>

//inherit mechanism class spec
class DCLiuSensor: public mechanism {

protected:

    // scalar
    double Mbar;
    double i_Ca;

public:
    double X;
    double m = 0;

    // parameters for DCLiuSensor
    double ZM;
    double tau_m;
    double G;


    DCLiuSensor(double ZM_, double tau_m_, double G_, double X_, double m_)
    {

        ZM = ZM_;
        tau_m = tau_m_;
        G = G_;
        X = X_;

        if (isnan(ZM)) {ZM = 3;}
        if (isnan(tau_m)) {tau_m = 500; } // msau_h = 60;} // ms
        if (isnan(G)) {G = 1;}
        if (isnan(X)) {X = 0;}
        if (isnan(m)) {m = 0;}

    }


    void integrate(void);


    void connect(compartment*);
    void connect(conductance*);
    void connect(synapse*);
    double boltzmann(double);
    string getClass(void);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);
    void checkSolvers(int);
};

    string DCLiuSensor::getClass() {
        return "DCLiuSensor";
    }


    double DCLiuSensor::getState(int idx) {return X;}


    int DCLiuSensor::getFullStateSize() {return 1;}

    int DCLiuSensor::getFullState(double *cont_state, int idx)
    {
        // return internal variable
        cont_state[idx] = X;
        idx++;
        return idx;
    }

    void DCLiuSensor::connect(compartment* comp_)
    {
        comp = comp_;
        comp->addMechanism(this);
    }

    void DCLiuSensor::connect(synapse* syn_)
    {
        mexErrMsgTxt("[DCLiuSensor] cannot be added to a synapse\n");
    }


    void DCLiuSensor::connect(conductance* cond_)
    {
        mexErrMsgTxt("[DCLiuSensor] cannot be added to a conductance\n");
    }

    void DCLiuSensor::integrate(void)
    {
        i_Ca = (comp->i_Ca_prev)/(comp->Cm);
        Mbar = boltzmann(ZM + i_Ca);

        //calculate dMx/dt and dHx/dt
        m = Mbar + (m - Mbar)*exp(-dt/tau_m);

        //integrate S
        X = G*m*m;
    }
    double DCLiuSensor::boltzmann(double x) {
      return 1/(1 + exp(x));
    }
    void DCLiuSensor::checkSolvers(int k)
    {
        if (k == 0){
            return;
        } else {
            mexErrMsgTxt("[DCLiuSensor] unsupported solver order\n");
        }
    }


#endif
