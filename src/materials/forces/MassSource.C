#include "MassSource.h"

registerADMooseObject("StingrayApp", MassSource);

InputParameters
MassSource::validParams()
{
  InputParameters params = ThermodynamicForce<Real>::validParams();
  params.addClassDescription("This class computes the mass source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_source", "Name of the mass source");
  params.addRequiredParam<VariableName>("concentration", "The concentration variable");
  return params;
}

MassSource::MassSource(const InputParameters & parameters) : ThermodynamicForce<Real>(parameters)
{
  const VariableName lnc_name = "ln(" + getParam<VariableName>("concentration") + ")";

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, lnc_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<Real>(getParam<MaterialPropertyName>("mass_source"));
}
