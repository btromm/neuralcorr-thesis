#ifndef _constants_H_
#define _constants_H_

/* Commonly Accepted Values. */
const double R = 8.314472;         // Gas constant (J K^-1 mol^-1)
const double F = 96485.3399;       // Faraday constant (C mol^-1)
const double c_density = 1;        // Capacitance per unit area [uF/cm^2].

// Equilibrium Potentials for the original Hodgkin-Huxley experiments.
const double E_Na = 50;    // Sodium equilibrium potential [mV].
const double E_K = -80;    // Potassium equilibrium potential [mV].
const double E_H = -20;    // Reversal Potential for H-current [mV].
const double E_leak = -50; // Reversal Potential for leak current [mV].

// External Calcium concentration, used to calculate E_Ca
const double Ca_external = 3000; // in [uM].
const double Temperature = 296.65; // in [Kelvin] from Turriagiano '95

// Used to size inputs
const int nConductances = 8; // 7 conductances in Fig 10, plus leak.
const int nStateVars = 32;   // Voltage, Ca, 8 max_gs, 16 channel gates, 6 sensor gates
const int nSensors = 3;      // Number of ADHR sensors
const int nSensorVars = nSensors*6; // Each sensor has 6 parameters
#endif
