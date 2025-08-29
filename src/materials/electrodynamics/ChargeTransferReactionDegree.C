// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "ChargeTransferReactionDegree.h"

registerMooseObject("EelApp", ChargeTransferReactionDegree);

InputParameters
ChargeTransferReactionDegree::validParams()
{
  InputParameters params = InterfaceMaterial::validParams();
  params.addClassDescription("The reaction degree of charge transfer.");
  params.addRequiredCoupledVar("concentration", "Concentration");
  params.addRequiredCoupledVar("neighbor_concentration", "Neighbor concentration");
  params.addRequiredParam<Real>("concentration_start", "Starting concentration");
  params.addRequiredParam<Real>("concentration_end", "Ending concentration");
  params.addRequiredParam<Real>("neighbor_concentration_start", "Starting neighbor concentration");
  params.addRequiredParam<Real>("neighbor_concentration_end", "Ending neighbor concentration");
  params.addRequiredParam<MaterialPropertyName>("reaction_degree",
                                                "The reaction degree of charge transfer");
  return params;
}

ChargeTransferReactionDegree::ChargeTransferReactionDegree(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    _r(declareADProperty<Real>("reaction_degree")),
    _c(adCoupledValue("concentration")),
    _c_min(getParam<Real>("concentration_start")),
    _c_max(getParam<Real>("concentration_end")),
    _c_neigh(adCoupledNeighborValue("neighbor_concentration")),
    _c_neigh_min(getParam<Real>("neighbor_concentration_start")),
    _c_neigh_max(getParam<Real>("neighbor_concentration_end"))
{
}

void
ChargeTransferReactionDegree::initQpStatefulProperties()
{
  computeQpProperties();
}

void
ChargeTransferReactionDegree::computeQpProperties()
{
  auto a = (_c[_qp] - _c_min) / (_c_max - _c_min);
  // if (a < 0)
  //   a = 0;
  // if (a > 1)
  //   a = 1;

  auto b = (_c_neigh[_qp] - _c_neigh_min) / (_c_neigh_max - _c_neigh_min);
  // if (b < 0)
  //   b = 0;
  // if (b > 1)
  //   b = 1;

  const auto fa = 3 * a * a - 2 * a * a * a;
  const auto fb = 3 * b * b - 2 * b * b * b;
  _r[_qp] = (fa + fb) / 2;
}
