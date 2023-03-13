#include "SDStress.h"

registerADMooseObject("EelApp", SDStress);

InputParameters
SDStress::validParams()
{
  InputParameters params = ThermodynamicForce<RankTwoTensor>::validParams();
  params.addClassDescription(
      "This class computes the small deformation Cauchy stress associated with "
      "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("cauchy_stress", "Name of the Cauchy stress");
  params.addRequiredParam<MaterialPropertyName>("strain_rate", "The strain rate");
  return params;
}

SDStress::SDStress(const InputParameters & parameters)
  : ThermodynamicForce<RankTwoTensor>(parameters)
{
  const MaterialPropertyName E_dot_name = getParam<MaterialPropertyName>("strain_rate");

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, E_dot_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RankTwoTensor>("cauchy_stress");
}
