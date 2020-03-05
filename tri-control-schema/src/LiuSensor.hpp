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

public:
    //iCa smoothed over different timescales
    double iCa_f = 0;
    double iCa_s = 0;
    double iCa_d = 0;

    double Mbar_f = 0;
    double Mbar_s = 0;
    double Mbar_d = 0;

    double Hbar_f = 0;
    double Hbar_s = 0;

    double Mf = 0;
    double Ms = 0;
    double Md = 0;

    double Hf = 0;
    double Hs = 0;
    double Hd = 0;


    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    LiuSensor(double iCa_f_, double iCa_s_, double iCa_d_, double Mf_, double Ms_, double Md_, double Hf_, double Hs_, double Mbar_f_, double Mbar_s_, double Mbar_d_, double Hbar_f_, double Hbar_s_)
    {
        iCa_f = iCa_f_;
        iCa_s = iCa_s_;
        iCa_d = iCa_d_;
        Mf = Mf_;
        Ms = Ms_;
        Md = Md_;
        Hf = Hf_;
        Hs = Hs_;
        Mbar_f = Mbar_f_;
        Mbar_s = Mbar_s_;
        Mbar_d = Mbar_d_;
        Hbar_f = Hbar_f_;
        Hbar_s = Hbar_s_;

        controlling_class = "LiuSensor";
    }


    void integrate(void);


    void connect(compartment*);
    void connect(conductance*);
    void connect(synapse*);
    string getClass(void);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);
    void checkSolvers(int);

};

string LiuSensor::getClass() {
    return "LiuSensor";
}


double LiuSensor::getState(int idx) {

    switch (idx) {

        case 0:
            return iCa_f;
            break;
        case 1:
            return iCa_s;
            break;
        case 2:
            return iCa_d;
            break;

    }
    return std::numeric_limits<double>::quiet_NaN();

}


int LiuSensor::getFullStateSize() {
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

    Mbar_f = 1.0/(1.0 + exp(14.2 + (comp->i_Ca_prev)*10));
    Mbar_s = 1.0/(1.0 + exp(7.2 + (comp->i_Ca_prev)*10));
    Mbar_d = 1.0/(1.0 + exp(3.0 + (comp->i_Ca_prev)*10));
    Mf = Mbar_f;
    Ms = Mbar_s;
    Md = Mbar_d;
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
    Mbar_f = 1.0/(1.0 + exp(14.2 + (comp->i_Ca_prev)*10));
    Mbar_s = 1.0/(1.0 + exp(7.2 + (comp->i_Ca_prev)*10));
    Mbar_d = 1.0/(1.0 + exp(3.0 + (comp->i_Ca_prev)*10));

    //calculate Hbar for each type
    Hbar_f = 1.0/(1.0 + exp(-9.8 - (comp->i_Ca_prev)));
    Hbar_s = 1.0/(1.0 + exp(-2.8 - (comp->i_Ca_prev)));

    //calculate dMx/dt for each type and dHx/dt for each type
    double dMfdt = (Mbar_f - Mf)/0.5;
    double dMsdt = (Mbar_s - Ms)/50;;
    double dMddt = (Mbar_d - Md)/500;

    double dHfdt = (Hbar_f - Hf)/1.5;
    double dHsdt = (Hbar_s - Hs)/60;

    //integrate Mx and Hx
    Mf = Mf + dMfdt*dt;
    Ms = Ms + dMsdt*dt;
    Md = Md + dMddt*dt;
    Hf = Hf + dHfdt*dt;
    Hs = Hs + dHsdt*dt;

    //integrate FSD
    iCa_f = 10.0*Mf*Mf*Hf;
    iCa_s = 3.0*Ms*Ms*Hs;
    iCa_d = 1.0*Md*Md;
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
