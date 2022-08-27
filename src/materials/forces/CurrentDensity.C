#include "CurrentDensity.h"

registerADMooseObject("StingrayApp", CurrentDensity);

InputParameters
CurrentDensity::validParams()
{
  InputParameters params = ThermodynamicForce<RealVectorValue>::validParams();
  params.addClassDescription("This class computes the current density associated with "
                             "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("current_density", "Name of the current density");
  params.addRequiredParam<VariableName>("electric_potential", "The electric potential");
  return params;
}

CurrentDensity::CurrentDensity(const InputParameters & parameters)
  : ThermodynamicForce<RealVectorValue>(parameters)
{
  const VariableName grad_Phi_name = "∇" + getParam<VariableName>("electric_potential");

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, grad_Phi_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RealVectorValue>(getParam<MaterialPropertyName>("current_density"));
}
