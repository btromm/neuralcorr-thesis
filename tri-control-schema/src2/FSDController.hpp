// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// Integral controller, as in O'Leary et al
// This controller can control either a synapse
// or a conductance

#ifndef FSDCONTROLLER
#define FSDCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class FSDController: public mechanism {

protected:
    //FSD G Variables
    double Gf = 10;
    double Gs = 3;
    double Gd = 1;
    double tau_Mx = 0;
    double tau_Hx = 0;
public:
    // timescales
    double tau_g = 5000; //ms

    //coupling parameters
    double A = 0;
    double B = 0;
    double C = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    FSDController(double A_, double B_, double C_, double tau_g_)
    {

        A = A_;
        B = B_;
        C = C_;
        tau_g = tau_g_;



        // if (tau_m<=0) {mexErrMsgTxt("[FSDController] tau_m must be > 0. Perhaps you meant to set it to Inf?\n");}
        if (tau_g<=0) {mexErrMsgTxt("[FSDController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
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

string FSDController::getClass() {
    return "FSDController";
}

//perhaps unimplemented
double FSDController::getState(int idx)
{
    return 0;
    //if (idx == 1) {return m;}
    //else if (idx == 2) {return channel->gbar;}
    //else {return std::numeric_limits<double>::quiet_NaN();}
}

// only thing we return is value of gbar
int FSDController::getFullStateSize(){return 1; }


int FSDController::getFullState(double *cont_state, int idx)
{
  cont_state[idx] = channel->gbar;
  idx++;
  return idx;
}


void FSDController::connect(conductance * channel_)
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

void FSDController::connect(compartment* comp_)
{
    mexErrMsgTxt("[FSDController] This mechanism cannot connect to a compartment object");
}

void FSDController::connect(synapse* syn_)
{
  mexErrMsgTxt("[FSDController] This mechanism cannot connect to a synapse object")
}


void FSDController::integrate(void)
{


    switch (control_type)
    {
        case 0:
            mexErrMsgTxt("[FSDController] misconfigured controller. Make sure this object is contained by a conductance or synapse object");
            break;


        case 1:

            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled
            // and do nothing
            if (isnan((channel->container)->Ca_target)) {return;}

            double Ca_error = (channel->container)->Ca_target - (channel->container)->Ca_prev;

            // integrate mRNA
            m += (dt/tau_m)*(Ca_error);

            // mRNA levels below zero don't make any sense
            if (m < 0) {m = 0;}

            // copy the protein levels from this channel
            double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

            // make sure it doesn't go below zero
            if (channel->gbar + gdot/container_A < 0) {
                channel->gbar = 0;
            } else {
                channel->gbar += gdot/container_A;
            }


            break;

            }
        case 2:
            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled
            // and do nothing

            if (isnan((syn->post_syn)->Ca_target)) {return;}

            double Ca_error = (syn->post_syn)->Ca_target - (syn->post_syn)->Ca_prev;

            // integrate mRNA
            m += (dt/tau_m)*(Ca_error);

            // mRNA levels below zero don't make any sense
            if (m < 0) {m = 0;}

            // copy the protein levels from this syn
            double gdot = ((dt/tau_g)*(m - syn->gmax*1e-3));

            // make sure it doesn't go below zero
            if (syn->gmax + gdot*1e3 < 0) {
                syn->gmax = 0;
            } else {
                syn->gmax += gdot*1e3;
            }


            break;

            }

        default:
            mexErrMsgTxt("[FSDController] misconfigured controller");
            break;

    }


}



void FSDController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[FSDController] unsupported solver order\n");
    }
}




#endif
