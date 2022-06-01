//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "FirstPiolaKirchhoffStress.h"

registerADMooseObject("StingrayApp", FirstPiolaKirchhoffStress);

InputParameters
FirstPiolaKirchhoffStress::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("This class computes the first Piola-Kirchhoff stress associated with "
                             "given energy densities.");

  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Vector of energy densities");

  return params;
}

FirstPiolaKirchhoffStress::FirstPiolaKirchhoffStress(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _PK1(declareADProperty<RankTwoTensor>(prependBaseName("first_piola_kirchhoff_stress"))),
    _psi_names(getParam<std::vector<MaterialPropertyName>>("energy_densities")),
    _d_psi_d_F(_psi_names.size())
{
  // Get thermodynamic forces
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_F[i] = &getADMaterialPropertyByName<RankTwoTensor>(derivativePropertyName(
        prependBaseName(_psi_names[i]), {prependBaseName("deformation_gradient")}));
}

void
FirstPiolaKirchhoffStress::computeQpProperties()
{
  _PK1[_qp].zero();
  for (const auto & d_psi_d_F : _d_psi_d_F)
    _PK1[_qp] += (*d_psi_d_F)[_qp];
}
