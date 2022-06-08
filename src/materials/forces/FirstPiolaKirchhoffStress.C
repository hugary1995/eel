//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

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
  return params;
}

FirstPiolaKirchhoffStress::FirstPiolaKirchhoffStress(const InputParameters & parameters)
  : ThermodynamicForce<RankTwoTensor>(parameters),
    _F(_heat ? &getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("deformation_gradient"))
             : nullptr),
    _F_old(_heat ? &getMaterialPropertyOldByName<RankTwoTensor>(
                       prependBaseName("deformation_gradient"))
                 : nullptr)
{
  // Get equilibrium forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, prependBaseName("deformation_gradient"));

  // Get viscous forces
  getThermodynamicForces(
      _d_psi_dis_d_v, _psi_dis_names, prependBaseName("deformation_gradient") + "_dot");

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<RankTwoTensor>(prependBaseName("first_piola_kirchhoff_stress", true));
}
