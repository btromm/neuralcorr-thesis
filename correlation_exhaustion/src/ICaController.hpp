// _  _ ____ _    ____ ___ _    
//  \/  |  | |    |  |  |  |    
// _/\_ |__| |___ |__|  |  |___ 
//
// this Controller uses a filtered version
// of iCa to control conductances 

#ifndef ICACONTROLLER
#define ICACONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class ICaController: public mechanism {

protected:
    // flag used to switch between
    // controlling channels and synapses
    // meaning:
    // 0 --- unset, will throw an error
    // 1 --- channels
    // 2 --- synapses
    int control_type = 0;

    double dt_by_tau_K = 0;

public:
    // timescales
    double tau_m = std::numeric_limits<double>::infinity();
    double tau_g = 5e3; 

    // mRNA concentration 
    double m = 0;

    // area of the container this is in
    double container_A;


    // additional parameters and variables
    double tau_K = std::numeric_limits<double>::quiet_NaN();
    double iCaLP = 0; // low pass iCa
    double iCaHP = 0; // high pass iCa
    double target = std::numeric_limits<double>::quiet_NaN();

    // specify parameters + initial conditions for 
    // mechanism that controls a conductance 
    ICaController(double tau_m_, double tau_g_, double m_, double tau_K_, double iCaLP_, double iCaHP_, double target_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        m = m_;
        tau_K = tau_K_;

        iCaLP = iCaLP_;
        iCaHP = iCaHP_;

        target = target_;

        if (tau_g<=0) {mexErrMsgTxt("[ICaController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
    }

    
    void integrate(void);

    void checkSolvers(int);

    void connect(conductance *);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);

};


double ICaController::getState(int idx) {
    if (idx == 1) {return m;}
    else if (idx == 2) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int ICaController::getFullStateSize(){return 3; }


int ICaController::getFullState(double *cont_state, int idx) {


    if (channel) {
      cont_state[idx] = iCaLP;  idx++;
      cont_state[idx] = iCaHP;  idx++;
      cont_state[idx] = channel->gbar;  idx++;
    }

    
    return idx;
}

// allow connections to a conductance
void ICaController::connect(conductance * channel_) {

   
    channel = channel_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel_->getClass()).c_str();

    // attempt to read the area of the container that this
    // controller should be in. 
    container_A  = (channel->container)->A;

    control_type = 1;

    dt_by_tau_K = exp(-dt/tau_K);


}


void ICaController::integrate(void) {


    switch (control_type)
    {
        case 0:
            mexErrMsgTxt("[ICaController] misconfigured controller. Make sure this object is contained by a conductance or synapse object");
            break;


        case 1:

            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled 
            // and do nothing 


            // read out i_Ca
            double iCa = (channel->container)->i_Ca_prev;

            // convolve with exponential smoothing filter
            iCaLP =  iCa + (iCaLP - iCa)*dt_by_tau_K;

            // estimate high pass contributions 
            iCaHP = abs(iCa - iCaLP);



            if (isnan(target)) {return;}

            double error = target - iCaHP;

            // integrate mRNA
            m += (dt/tau_m)*(error);

            // mRNA levels below zero don't make any sense
            if (m < 0) {m = 0;}

            // copy the protein levels from this channel
            double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

            // make sure it doesn't go below zero
            if (channel->gbar_next + gdot < 0) {
                channel->gbar_next = 0;
            } else {
                channel->gbar_next += gdot/container_A;
            }


            break;

            }

        default:
            mexErrMsgTxt("[ICaController] misconfigured controller");
            break;

    }


}



void ICaController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[ICaController] unsupported solver order\n");
    }
}




#endif
