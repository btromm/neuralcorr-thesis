#include <vector>
#include <cmath>
#include "mex.h"
#include "liuConstants.h"
#include "Compartment.h"
#include "Liu_NaChannel.h"
#include "Liu_CaTChannel.h"
#include "Liu_CaSChannel.h"
#include "Liu_AChannel.h"
#include "Liu_KcaChannel.h"
#include "Liu_KdChannel.h"
#include "Liu_HChannel.h"
#include "LeakChannel.h"

using namespace std;

//plhs = parameters left hand side (so outputs of the mexFunction)
//prhs = parameters right hand side (so inputs of the mexFunction)
void mexFunction( int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[] )
{
  // Declarations.
  double  *timeParams_in;
  double  tMax, dt, res, tauG_in;           // Simulation params
  vector< double >  g_max_in, state_in, sensor_params_in, t_out;
  vector< vector< double > > reg_map_in, state_out;
  double  *ep;
  bool ADHR_switch;
  
  // Check if the method call has correct form.
  if(nrhs < 4)
    mexErrMsgTxt("Minimum of four inputs.");
  if(nrhs > 5)
    mexErrMsgTxt("Maximum of five inputs.");
  if(nlhs > 2)
    mexErrMsgTxt("Maximum of two outputs");

  
  /************************************************************************
  ******************** READ IN ALL INPUTS FROM MATLAB *********************
  ************************************************************************/
  
  // First input is the time parameters of the simulation.
  if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || 
          mxGetN(prhs[0]) != 1  || mxGetM(prhs[0]) != 5) {
    mexErrMsgTxt("First input must be a column vector with 5 elements.");
  }
  timeParams_in  = mxGetPr(prhs[0]);
  tMax           = timeParams_in[0];
  dt             = timeParams_in[1];
  res            = timeParams_in[2];
  if(timeParams_in[3]==1) {
    ADHR_switch = true;
    //mexPrintf("ADHR is ON\n");
  }
  else {
    ADHR_switch = false;
    //mexPrintf("ADHR is OFF\n");
  }
  tauG_in = timeParams_in[4];
  
  // Second input is the maximal conductance vector. For the Liu model, we
  /// want to have the conductances in the order specified by Figure 10:
  ///
  ///   0--> Sodium
  ///   1--> CaT
  ///   2--> CaS
  ///   3--> A
  ///   4--> KCa
  ///   5--> Kd
  ///   6--> H
  ///   7--> leak
  ///
  /// It is important to maintain this order at all times. This order is
  /// also used for printing and setting the state variables.
  if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || 
          mxGetN(prhs[1]) != 1  || mxGetM(prhs[1]) != nConductances) {
    mexErrMsgTxt("Second input must be a column vector holding all the maximal conductances.");
  }
  ep = mxGetPr(prhs[1]);      // Copy information into "g_max_in"
  g_max_in.resize( nConductances );
  for( int i = 0; i < nConductances; i++,ep++ )
    g_max_in[i] = *ep;
  
  // Third input is the vector defining the parameters for the LiuSensors
  if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || 
          mxGetN(prhs[2]) != 1  || mxGetM(prhs[2]) != nSensorVars) {
    mexErrMsgTxt("Third input must be a column vector holding info about the ADHR sensors.");
  }
  ep = mxGetPr(prhs[2]);      // Copy information into "sensor_params_in"
  sensor_params_in.resize( nSensorVars );
  for( int i = 0; i < nSensorVars; i++,ep++ )
    sensor_params_in[i] = *ep;
  
  // Fourth input sets regulation map - which maps the sensors to the ion
  /// channels that they regulate. 
  if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || 
          mxGetN(prhs[3]) != nSensors  || mxGetM(prhs[3]) != nConductances) {
    mexErrMsgTxt("Fourth input must be a column vector holding the regulation map.");
  }
  ep = mxGetPr(prhs[3]);      // Copy information into "reg_map_in"
  reg_map_in.resize( nSensors );
  for( int i = 0; i < nSensors; i++ ) {
    reg_map_in[i].resize( nConductances );
    for( int j = 0; j < nConductances; j++,ep++) {
      reg_map_in[i][j] = *ep; // Need to transpose for MATLAB compatibility
      // mexPrintf("%1.1f ",*ep);
    }
    // mexPrintf("\n");
  }
  
  // Fifth input (optional). Set the initial condition for the network.
  if (nrhs >= 5) {
    if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || 
            mxGetN(prhs[4]) != 1  || mxGetM(prhs[4]) != nStateVars) {
      mexErrMsgTxt("Fifth input must be a column vector holding all the state variables.");
    }
    ep = mxGetPr(prhs[4]);      // Copy information into "state_in"
    state_in.resize( nStateVars );
    mexPrintf("state_in: ");
    for( int i = 0; i < nStateVars; i++,ep++ ) {
      state_in[i] = *ep;
      mexPrintf("%3.4f  ",*ep); 
    }
    mexPrintf("\n");
  }
  
// NO NEED FOR INJECTED CURRENT AT THE MOMENT
//
//   // Third input is the vector specifying the injected current. The units
//   /// for current are [nA/cm^2]
//   if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || 
//           mxGetN(prhs[2]) != 1  || mxGetM(prhs[2]) != int(tMax/dt)) {
//     mexErrMsgTxt("Third input must be a column vector with tMax/dt elements.");
//   }
//   ep = mxGetPr(prhs[2]);            // Copy information into "I_ext_in"
//   I_ext_in.resize( int(tMax/dt) );  // tMax/dt ==> # of time points.
//   for( int i = 0; i < int(tMax/dt); i++,ep++ )
//     I_ext_in[i] = *ep;
 
  
  /************************************************************************
  *************************** RUN THE SIMULATION **************************
  ************************************************************************/
  
  // Create an iso-potential neuron.
  Compartment cell(-46.8,ADHR_switch);
  // Set all the maximal conductances and initialize calcium
  cell.pushChannel(new Liu_NaChannel(g_max_in[0],tauG_in));
  cell.pushChannel(new Liu_CaTChannel(g_max_in[1],tauG_in));
  cell.pushChannel(new Liu_CaSChannel(g_max_in[2],tauG_in));
  cell.pushChannel(new Liu_AChannel(g_max_in[3],tauG_in));
  cell.pushChannel(new Liu_KcaChannel(g_max_in[4],tauG_in));
  cell.pushChannel(new Liu_KdChannel(g_max_in[5],tauG_in));
  cell.pushChannel(new Liu_HChannel(g_max_in[6],tauG_in));
  cell.pushChannel(new LeakChannel(g_max_in[7],tauG_in));
  // Include the ADHR sensors
  for(int i = 0; i < nSensors; i++) {
    cell.pushSensor(LiuSensor(sensor_params_in[(i*6)+0],   // target level
                              sensor_params_in[(i*6)+1],   // G_max
                              sensor_params_in[(i*6)+2],   // tauM
                              sensor_params_in[(i*6)+3],   // tauH
                              sensor_params_in[(i*6)+4],   // Z_M
                              sensor_params_in[(i*6)+5]),  // Z_H
                    reg_map_in[i]);
  }
  
  // Re-size output vectors.
  state_out.resize(int(tMax/res));
  t_out.resize(int(tMax/res));
  
  // If specified, set the initial cell state.
  if( nrhs >= 5 )
    cell.setState(state_in);
  
  // Iterate through each time step. Update the compartment, and then store
  /// the cell state in the "state_out" vector. The "dt" time step
  /// specifies how big of an integration step to take. The "res" time step
  /// specifies how often the data is sampled and stored in "state_out"
  ///
  /// The "i" indexing variable is used for vectors with "res" time steps,
  /// while the "n" indexes vectors with "dt" time steps.
  for(size_t n = 0; n < size_t(tMax/res); n++){

    // Update cell "res" time steps.
    for( size_t h = 0; h < size_t(res/dt); h++ ) {
      cell.updateCompartment(dt); // Numerical integration happens here.
    }
    
    // Every "res" milliseconds we sample the state of the system. Need to
    /// have this step after updateCompartment to have the simulation be
    /// continuous.
    t_out[n] = double(n)*res;
    cell.getState(state_out[n]);
  }
  
  /************************************************************************
  ******************** PRINT OUT ALL OUTPUTS TO MATLAB ********************
  ************************************************************************/
  
  // First output is the time vector.
  if (nlhs>=1) {
    plhs[0] = mxCreateDoubleMatrix(t_out.size(), 1, mxREAL);
    ep = mxGetPr(plhs[0]);
    for (size_t i=0; i<t_out.size(); i++,ep++)
      *ep=t_out[i];
  }
   
  // Second output is the cell state variables. Because C++ vectors are
  /// organized in row-major order, and we want to output the variables
  /// in column-major order, we need to iterate over the state variables
  /// in the outer loop and over time in the inner loop.
  if (nlhs>=2) {
    plhs[1] = mxCreateDoubleMatrix(state_out.size(),
                                   state_out[0].size(),
                                   mxREAL);
    ep = mxGetPr(plhs[1]);
    for (size_t i=0; i<state_out[0].size(); i++)
      for (size_t j=0; j<state_out.size(); j++,ep++)
        *ep=state_out[j][i];
  }
}
