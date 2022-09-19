#include "MassFlux.h"

registerADMooseObject("EelApp", MassFlux);

InputParameters
MassFlux::validParams()
{
  InputParameters params = ThermodynamicForce<RealVectorValue>::validParams();
  params.addClassDescription("This class computes the mass flux associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "Name of the mass flux");
  params.addRequiredParam<MaterialPropertyName>("chemical_potential",
                                                "The chemical potential variable");
  params.set<Real>("factor") = 1;
  params.suppressParameter<Real>("factor");
  return params;
}

MassFlux::MassFlux(const InputParameters & parameters)
  : ThermodynamicForce<RealVectorValue>(parameters)
{
  const VariableName grad_mu_name = "∇" + getParam<MaterialPropertyName>("chemical_potential");

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, grad_mu_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RealVectorValue>(getParam<MaterialPropertyName>("mass_flux"));
}
