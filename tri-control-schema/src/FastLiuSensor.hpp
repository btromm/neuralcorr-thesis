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

#ifndef FASTLIUSENSOR
#define FASTLIUSENSOR
#include "mechanism.hpp"
#include <limits>

//inherit mechanism class spec
class FastLiuSensor: public mechanism {

protected:

    // scalar
    double Mbar;
    double Hbar;
    double i_Ca;

public:
    double X;
    double m = 0;
    double h = 1;

    // parameters for FastLiuSensor
    double ZM;
    double ZH;
    double tau_m;
    double tau_h;
    double G;


    FastLiuSensor(double ZM_, double ZH_, double tau_m_, double tau_h_, double G_, double X_, double m_, double h_)
    {

        ZM = ZM_;
        ZH = ZH_;
        tau_m = tau_m_;
        tau_h = tau_h_;
        G = G_;
        X = X_;

        if (isnan(ZM)) {ZM = 14.2;}
        if (isnan(ZH)) {ZH = 9.8;}
        if (isnan(tau_m)) {tau_m = .5; } // ms
        if (isnan(tau_h)) {tau_h = 1.5;} // ms
        if (isnan(G)) {G = 10;}
        if (isnan(X)) {X = 0;}
        if (isnan(m)) {m = 0;}
        if (isnan(h)) {h = 1;}

        controlling_class = "FastLiuSensor";
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

    string FastLiuSensor::getClass() {
        return "FastLiuSensor";
    }


    double FastLiuSensor::getState(int idx) {return X;}


    int FastLiuSensor::getFullStateSize() {return 1;}

    int FastLiuSensor::getFullState(double *cont_state, int idx)
    {
        // return internal variable
        cont_state[idx] = X;
        idx++;
        return idx;
    }

    void FastLiuSensor::connect(compartment* comp_)
    {
        comp = comp_;
        comp->addMechanism(this);
    }

    void FastLiuSensor::connect(synapse* syn_)
    {
        mexErrMsgTxt("[FastLiuSensor] cannot be added to a synapse\n");
    }


    void FastLiuSensor::connect(conductance* cond_)
    {
        mexErrMsgTxt("[FastLiuSensor] cannot be added to a conductance\n");
    }

    void FastLiuSensor::integrate(void)
    {
        i_Ca = (comp->i_Ca_prev)/(comp->Cm);
        Mbar = boltzmann(ZM + i_Ca);
        Hbar = boltzmann(-ZH - i_Ca);

        //calculate dMx/dt and dHx/dt
        m = Mbar + (m - Mbar)*exp(-dt/tau_m);
        h = Hbar + (h - Hbar)*exp(-dt/tau_h);

        //integrate F
        X = G*m*m*h;
    }
    double FastLiuSensor::boltzmann(double x) {
      return 1/(1 + exp(x));
    }
    void FastLiuSensor::checkSolvers(int k)
    {
        if (k == 0){
            return;
        } else {
            mexErrMsgTxt("[FastLiuSensor] unsupported solver order\n");
        }
    }


#endif
