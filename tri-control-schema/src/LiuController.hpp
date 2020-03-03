// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// FSD Controller, as in Liu et al.
// This controller can control a conductance

#ifndef LIUCONTROLLER
#define LIUCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class LiuController: public mechanism {

protected:

  // equilibrium values
  // in all cases, D = 0.1
  // combinations per Liu et al -- 0.25/0.09, 0.2/0.09, 0.06/0.09,
  // .15/.045, .2/.045, .06/.045
  double Fbar = 0.25;
  double Sbar = 0.09;
  double Dbar = 0.1;

public:
    // timescales
    double tau_g = 5e3; //ms

    //coupling parameters
    double A = 0;
    double B = 0;
    double C = 0;


    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    LiuController(double A_, double B_, double C_, double tau_g_)
    {

        A = A_;
        B = B_;
        C = C_;

        tau_g = tau_g_;



        if (tau_g<=0) {mexErrMsgTxt("[LiuController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
    }


    void integrate(void);

    void checkSolvers(int);

    void connect(conductance *);
    void connect(synapse*);
    void connect(compartment*);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);
    string getClass(void);

};

string LiuController::getClass() {
    return "LiuController";
}

double LiuController::getState(int idx)
{
    if (idx == 1) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}
}

int LiuController::getFullStateSize(){return 1; }


int LiuController::getFullState(double *cont_state, int idx)
{
  cont_state[idx] = channel->gbar;
  idx++;
  return idx;
}


void LiuController::connect(conductance * channel_)
{

    // connect to a channel
    channel = channel_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel_->getClass()).c_str();

    // attempt to read the area of the container that this
    // controller should be in.
    container_A  = (channel->container)->A;

    mechanism* target = (channel->container)->getMechanismPointer("LiuSensor");

    mexPrintf("%f\n",container_A);
    mexPrintf("%f\n",target.iCa_d);

}

void LiuController::connect(compartment* comp_)
{
    mexErrMsgTxt("[LiuController] This mechanism cannot connect to a compartment object");
}

void LiuController::connect(synapse* syn_)
{
  mexErrMsgTxt("[LiuController] This mechanism cannot connect to a synapse object");
}


void LiuController::integrate(void)
{

  double deltag = ((A*(Fbar - target->iCa_f) + B*(Sbar - target->iCa_s) + C*(Dbar - target->iCa_d))*(channel->gbar)*container_A)*(dt/tau_g);



  if (channel->gbar_next + deltag < 0) {
      channel->gbar_next = 0;
  } else {
      channel->gbar_next += deltag;
  }
}



void LiuController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[LiuController] unsupported solver order\n");
    }
}




#endif
