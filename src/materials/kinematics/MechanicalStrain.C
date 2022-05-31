// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "MechanicalStrain.h"

registerADMooseObject("EelApp", MechanicalStrain);

InputParameters
MechanicalStrain::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription(
      "Compute mechanical strain by subtracting eigenstrains from the total strain");
  params.addRequiredParam<MaterialPropertyName>("strain", "Name of the total strain");
  params.addRequiredParam<MaterialPropertyName>("mechanical_strain",
                                                "Name of the mechanical strain");
  params.addRequiredParam<MaterialPropertyName>("eigen_strain", "Name of the total eigenstrain");
  params.addParam<MaterialPropertyName>("swelling_strain",
                                        "Name of the swelling strain, if applicable");
  params.addParam<MaterialPropertyName>("thermal_strain",
                                        "Name of the thermal strain, if applicable");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

MechanicalStrain::MechanicalStrain(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _E(getADMaterialProperty<RankTwoTensor>("strain")),
    _Es(isParamValid("swelling_strain") ? &getADMaterialProperty<RankTwoTensor>("swelling_strain")
                                        : nullptr),
    _Et(isParamValid("thermal_strain") ? &getADMaterialProperty<RankTwoTensor>("thermal_strain")
                                       : nullptr),
    _Em(declareADProperty<RankTwoTensor>("mechanical_strain")),
    _Eg(declareADProperty<RankTwoTensor>("eigen_strain"))
{
}

void
MechanicalStrain::initQpStatefulProperties()
{
  _Em[_qp].zero();
}

void
MechanicalStrain::computeQpProperties()
{
  // Total eigenstrain
  _Eg[_qp].zero();
  if (_Es)
    _Eg[_qp] += (*_Es)[_qp];
  if (_Et)
    _Eg[_qp] += (*_Et)[_qp];

  // Remove eigenstrain from total strain
  _Em[_qp] = _E[_qp] - _Eg[_qp];
}
