// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "EmbeddedMaterialAnisotropy.h"

registerMooseObject("EelApp", EmbeddedMaterialAnisotropy);

InputParameters
EmbeddedMaterialAnisotropy::validParams()
{
  InputParameters params = EmbeddedMaterialUnsignedDistance::validParams();
  params.addClassDescription("This class make an isotropic material property anisotropic by "
                             "considering the material embedding.");
  params.addRequiredParam<MaterialPropertyName>("isotropic_prop",
                                                "Name of the isotropic material property");
  params.addRequiredParam<MaterialPropertyName>("anisotropic_prop",
                                                "Name of the anisotropic material property");
  params.addRequiredParam<Real>("width", "Width of the embedded material");
  return params;
}

EmbeddedMaterialAnisotropy::EmbeddedMaterialAnisotropy(const InputParameters & params)
  : EmbeddedMaterialUnsignedDistance(params),
    _in(getADMaterialProperty<Real>("isotropic_prop")),
    _out(declareADProperty<RankTwoTensor>("anisotropic_prop")),
    _b(getParam<Real>("width"))
{
}

void
EmbeddedMaterialAnisotropy::computeQpProperties()
{
  EmbeddedMaterialUnsignedDistance::computeQpProperties();

  _out[_qp] = _in[_qp] * ADRankTwoTensor::Identity();
  if (_dist[_qp] < _b)
  {
    auto N = ADRankTwoTensor::outerProduct(_normal[_qp], _normal[_qp]);
    _out[_qp] -= _in[_qp] * N * (1.0 - 1e-6);
  }
}
