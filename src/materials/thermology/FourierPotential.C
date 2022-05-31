// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "FourierPotential.h"

registerMooseObject("EelApp", FourierPotential);

InputParameters
FourierPotential::validParams()
{
  InputParameters params = ThermalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Fourier potential for heat conduction.");
  params.addRequiredParam<MaterialPropertyName>("thermal_conductivity",
                                                "The thermal conductivity tensor");
  return params;
}

FourierPotential::FourierPotential(const InputParameters & parameters)
  : ThermalEnergyDensity(parameters), _kappa(getADMaterialProperty<Real>("thermal_conductivity"))
{
}

void
FourierPotential::computeQpProperties()
{
  _d_H_d_grad_lnT[_qp] = _kappa[_qp] * _grad_T[_qp];
  _H[_qp] = 0.5 * _d_H_d_grad_lnT[_qp] * _grad_T[_qp] / _T[_qp];
}
