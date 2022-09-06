#include "HeatConduction.h"

registerMooseObject("StingrayApp", HeatConduction);

InputParameters
HeatConduction::validParams()
{
  InputParameters params = ThermalEnergyDensity::validParams();
  params.addClassDescription(params.getClassDescription() +
                             " This class defines the Fourier potential for heat conduction.");
  params.addRequiredParam<MaterialPropertyName>("thermal_conductivity",
                                                "The thermal conductivity tensor");
  return params;
}

HeatConduction::HeatConduction(const InputParameters & parameters)
  : ThermalEnergyDensity(parameters), _kappa(getADMaterialProperty<Real>("thermal_conductivity"))
{
}

void
HeatConduction::computeQpProperties()
{
  _d_H_d_grad_lnT[_qp] = _kappa[_qp] * _grad_T[_qp];
  _H[_qp] = 0.5 * _d_H_d_grad_lnT[_qp] * _grad_T[_qp] / _T[_qp];
}
