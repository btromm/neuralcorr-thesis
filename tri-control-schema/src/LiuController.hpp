// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// Integral controller, as in O'Leary et al
// This controller can control either a synapse
// or a conductance

#ifndef LIUCONTROLLER
#define LIUCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class LiuController: public mechanism {

protected:
public:
    // timescales
    double tau_g = 5e3; //ms

    //coupling parameters
    double A = 0;
    double B = 0;
    double C = 0;

    //equilibrium values -- unique parameter model must be integrated continuously before applying controller to determine equilibrium values
    double Fbar = 0;
    double Sbar = 0;
    double Dbar = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    LiuController(double tau_g_, double A_, double B_, double C_, double Fbar_, double Sbar_, double Dbar_)
    {

        A = A_;
        B = B_;
        C = C_;
        tau_g = tau_g_;
        Fbar = Fbar_;
        Sbar = Sbar_;
        Dbar = Dbar_;



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
      channel->gbar_next += deltag/container_A;
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
