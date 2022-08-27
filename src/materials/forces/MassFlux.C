#include "MassFlux.h"

registerADMooseObject("StingrayApp", MassFlux);

InputParameters
MassFlux::validParams()
{
  InputParameters params = ThermodynamicForce<RealVectorValue>::validParams();
  params.addClassDescription("This class computes the mass flux associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "Name of the mass flux");
  params.addRequiredParam<VariableName>("concentration", "The concentration variable");
  return params;
}

MassFlux::MassFlux(const InputParameters & parameters)
  : ThermodynamicForce<RealVectorValue>(parameters)
{
  const VariableName grad_lnc_name = "∇ln(" + getParam<VariableName>("concentration") + ")";

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, grad_lnc_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RealVectorValue>(getParam<MaterialPropertyName>("mass_flux"));
}
