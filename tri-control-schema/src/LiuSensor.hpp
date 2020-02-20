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

#ifndef LIUSENSOR
#define LIUSENSOR
#include "mechanism.hpp"
#include <limits>

//inherit mechanism class spec
class LiuSensor: public mechanism {

protected:

    // scalar
    double G_f = 10;
    double G_s = 3;
    double G_d = 1;

    // inactivation variables
    double tau_Hf = 1.5e-3;
    double tau_Hs = 60e-3;
    // no inactivation variable for D


public:
    //iCa smoothed over different timescales
    double iCa_f;
    double iCa_s;
    double iCa_d;

    double Mf;
    double Ms;
    double Md;

    double Hf;
    double Hs;
    double Hd;


    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    LiuSensor(double iCa_f_, double iCa_s_, double iCa_d_, double Mf_, double Ms_, double Md_, double Hf_, double Hs_)
    {
        iCa_f = iCa_f_;
        iCa_s = iCa_s_;
        iCa_d = iCa_d_;
        Mf = Mf_;
        Ms = Ms_;
        Md = Md_;
        Hf = Hf_;
        Hs = Hs_;

        controlling_class = "unset";
    }


    void integrate(void);


    void connect(compartment*);
    void connect(conductance*);
    void connect(synapse*);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);
    void checkSolvers(int);

};


double LiuSensor::getState(int idx)
{

    return std::numeric_limits<double>::quiet_NaN();

}


int LiuSensor::getFullStateSize()
{
    return 3;
}

int LiuSensor::getFullState(double *cont_state, int idx)
{
    // return internal variable
    cont_state[idx] = iCa_f;
    idx++;
    cont_state[idx] = iCa_s;
    idx++;
    cont_state[idx] = iCa_d;
    idx++;
    return idx;
}

// need to modify this
void LiuSensor::connect(compartment* comp_)
{
    comp = comp_;
    comp->addMechanism(this);
}

void LiuSensor::connect(synapse* syn_)
{
    mexErrMsgTxt("[LiuSensor] cannot be added to a synapse\n");
}


void LiuSensor::connect(conductance* cond_)
{
    mexErrMsgTxt("[LiuSensor] cannot be added to a conductance\n");
}

void LiuSensor::integrate(void)
{
    // calculate Mbar for each type
    double Mbar_f = 1.0/(1.0 + exp(14.2 + (comp->i_Ca_prev)));
    double Mbar_s = 1.0/(1.0 + exp(7.2 + (comp->i_Ca_prev)));
    double Mbar_d = 1.0/(1.0 + exp(3.0 + (comp->i_Ca_prev)));

    //calculate Hbar for each type
    double Hbar_f = 1.0/(1.0 + exp(-9.8 - (comp->i_Ca_prev)));
    double Hbar_s = 1.0/(1.0 + exp(-2.8 - (comp->i_Ca_prev)));

    //calculate dMx/dt for each type and dHx/dt for each type
    double dMfdt = (Mbar_f - Mf)/0.5e-3;
    double dMsdt = (Mbar_s - Ms)/50e-3;;
    double dMddt = (Mbar_d - Md)/500e-3;

    double dHfdt = (Hbar_f - Hf)/1.5e-3;
    double dHsdt = (Hbar_s - Hs)/60e-3;

    //integrate Mx and Hx
    Mf = Mf + dMfdt;
    Ms = Ms + dMsdt;
    Md = Md + dMddt;
    Hf = Hf + dHfdt;
    Hs = Hs + dHsdt;

    //integrate FSD
    iCa_f = 10.0*(pow(Mf,2.0))*Hf;
    iCa_s = 3.0*(pow(Ms,2.0))*Hs;
    iCa_d = 1.0*(pow(Md,2.0));
}

void LiuSensor::checkSolvers(int k)
{
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[LiuSensor] unsupported solver order\n");
    }
}


#endif
