// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "PK1ToPK2.h"

registerMooseObject("EelApp", PK1ToPK2);

InputParameters
PK1ToPK2::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("This class converts PK1 stress to PK2 stress.");
  params.addRequiredParam<MaterialPropertyName>("deformation_gradient",
                                                "Name of the deformation gradient");
  params.addRequiredParam<MaterialPropertyName>("pk1", "Name of the PK1 stress tensor");
  params.addRequiredParam<MaterialPropertyName>("pk2", "Name of the PK2 stress tensor");
  params.suppressParameter<bool>("use_displaced_mesh");
  return params;
}

PK1ToPK2::PK1ToPK2(const InputParameters & parameters)
  : Material(parameters),
    _S(declareADProperty<RankTwoTensor>("pk2")),
    _F(getADMaterialProperty<RankTwoTensor>("deformation_gradient")),
    _P(getADMaterialProperty<RankTwoTensor>("pk1"))
{
}

void
PK1ToPK2::computeQpProperties()
{
  // P = FS
  // S = F^{-1} P
  _S[_qp] = _F[_qp].inverse() * _P[_qp];
  _S[_qp] = (_S[_qp] + _S[_qp].transpose()) / 2;
}
