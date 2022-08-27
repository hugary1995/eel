#include "FirstPiolaKirchhoffStress.h"

registerADMooseObject("StingrayApp", FirstPiolaKirchhoffStress);

InputParameters
FirstPiolaKirchhoffStress::validParams()
{
  InputParameters params = ThermodynamicForce<RankTwoTensor>::validParams();
  params.addClassDescription("This class computes the first Piola-Kirchhoff stress associated with "
                             "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("first_piola_kirchhoff_stress",
                                                "Name of the first Piola-Kirchhoff stress");
  params.addRequiredParam<MaterialPropertyName>("deformation_gradient", "The deformation gradient");
  return params;
}

FirstPiolaKirchhoffStress::FirstPiolaKirchhoffStress(const InputParameters & parameters)
  : ThermodynamicForce<RankTwoTensor>(parameters)
{
  const MaterialPropertyName F_dot_name =
      "dot(" + getParam<MaterialPropertyName>("deformation_gradient") + ")";

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, F_dot_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RankTwoTensor>("first_piola_kirchhoff_stress");
}
