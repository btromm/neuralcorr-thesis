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
  //pointers to sensor
  mechanism* Fast = 0;
  mechanism* Slow = 0;
  mechanism* DC = 0;

  int sensor_connected = 0;

  // equilibrium values
  // in all cases, D = 0.1
  // combinations per Liu et al -- 0.25/0.09, 0.2/0.09, 0.06/0.09,
  // .15/.045, .2/.045, .06/.045


public:
    // timescales
    double tau_g = 5e3; //ms

    //coupling parameters
    double A = 0;
    double B = 0;
    double C = 0;

    double Fbar = 0.25;
    double Sbar = 0.09;
    double Dbar = 0.1;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    LiuController(double A_, double B_, double C_, double tau_g_, double Fbar_, double Sbar_, double Dbar_)
    {

        A = A_;
        B = B_;
        C = C_;

        Fbar = Fbar_;
        Sbar = Sbar_;
        Dbar = Dbar_;

        if(isnan(Fbar)) {Fbar = 0.25;}
        if(isnan(Sbar)) {Sbar = 0.09;}
        if(isnan(Dbar)) {Dbar = 0.1;}

        tau_g = tau_g_;

        if(isnan(tau_g)) {tau_g = 5000;} //ms



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

}

void LiuController::connect(compartment* comp_)
{
    mexErrMsgTxt("[LiuController] This mechanism cannot connect to a compartment object");
}

void LiuController::connect(synapse* syn_)
{
  mexErrMsgTxt("[LiuController] This mechanism cannot connect to a synapse object");
}


void LiuController::integrate(void) {

  if(target)
  {
    target = (channel->container)->getMechanismPointer("LiuSensor");
  }
  // you need to read out all the variables from the target using the
  // "getState" method, because that is declared in mechanism
  // clunky, but the only way to do it in C++ (I think)
  double iCa_f = target->getState(0);
  double iCa_s = target->getState(1);
  double iCa_d = target->getState(2);

  double deltag = ((A*(Fbar - iCa_f) + B*(Sbar - iCa_s) + C*(Dbar - iCa_d))*(channel->gbar)*container_A)*(dt/tau_g);



  if (channel->gbar_next + deltag < 0) {
      channel->gbar_next = 0;
  } else {
      channel->gbar_next += deltag / container_A;
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
