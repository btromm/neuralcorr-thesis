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


public:
    // timescales
    double tau_g = 5e3; //ms

    //coupling parameters
    double A = 0;
    double B = 0;
    double C = 0;

    double Fbar = 0;
    double Sbar = 0;
    double Dbar = 0;

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
    void connectToLiuSensor(void);

};

void LiuController::connectToLiuSensor() {
  int n_mech = (channel->container)->n_mech;

  for(int i = 0; i < n_mech; i++) {
    string this_mech = (channel->container)->getMechanismPointer(i)->getClass().c_str();

    if(this_mech == "FastLiuSensor") {
      Fast = (channel->container)->getMechanismPointer(i);
      sensor_connected++;
    }
    if(this_mech == "SlowLiuSensor") {
      Slow = (channel->container)->getMechanismPointer(i);
      sensor_connected++;
    }
    if(this_mech == "DCLiuSensor") {
      DC = (channel->container)->getMechanismPointer(i);
      sensor_connected++;
    }
  }
}

string LiuController::getClass() {
    return "LiuController";
}

double LiuController::getState(int idx) {return 0;}

int LiuController::getFullStateSize() {return 0;}


int LiuController::getFullState(double *cont_state, int idx)
{
  return idx;
}


void LiuController::connect(conductance * cond_)
{

    // connect to a channel
    channel = cond_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel->getClass()).c_str();

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

  switch(sensor_connected){
    case 0:
      connectToLiuSensor();
      break;
    default:
      break;
  }

  double iCa_f = Fast->getState(0);
  double iCa_s = Slow->getState(0);
  double iCa_d = DC->getState(0);

  double deltag = ((A*(Fbar - iCa_f) + B*(Sbar - iCa_s) + C*(Dbar - iCa_d)))*(dt/tau_g)*(channel->gbar);



  if ((channel->gbar + deltag) > 0) {
    channel->gbar += deltag;
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
