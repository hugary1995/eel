//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ElectricDisplacement.h"

registerADMooseObject("StingrayApp", ElectricDisplacement);

InputParameters
ElectricDisplacement::validParams()
{
  InputParameters params = ThermodynamicForce<RealVectorValue>::validParams();
  params.addClassDescription("This class computes the electric displacement associated with "
                             "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("electric_displacement",
                                                "Name of the electric displacement");
  params.addRequiredCoupledVar("electric_potential", "The electric potential variable");
  return params;
}

ElectricDisplacement::ElectricDisplacement(const InputParameters & parameters)
  : ThermodynamicForce<RealVectorValue>(parameters),
    _Phi_name(getVar("electric_potential", 0)->name()),
    _grad_Phi_dot(_heat ? &adCoupledGradientDot("electric_potential") : nullptr)
{
  // Get equilibrium forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, "grad_" + _Phi_name);

  // Get viscous forces
  getThermodynamicForces(_d_psi_dis_d_v, _psi_dis_names, "grad_" + _Phi_name + "_dot");

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RealVectorValue>(prependBaseName("electric_displacement", true));
}
