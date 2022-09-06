#include "HeatSource.h"

registerADMooseObject("EelApp", HeatSource);

InputParameters
HeatSource::validParams()
{
  InputParameters params = ThermodynamicForce<Real>::validParams();
  params.addClassDescription("This class computes the heat source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("heat_source", "Name of the heat source");
  params.addRequiredParam<VariableName>("temperature", "The temperature variable");
  return params;
}

HeatSource::HeatSource(const InputParameters & parameters) : ThermodynamicForce<Real>(parameters)
{
  const VariableName lnT_name = "ln(" + getParam<VariableName>("temperature") + ")";

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, lnT_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<Real>(getParam<MaterialPropertyName>("heat_source"));
}
