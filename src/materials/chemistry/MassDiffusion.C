#include "MassDiffusion.h"

registerMooseObject("EelApp", MassDiffusion);

InputParameters
MassDiffusion::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params.addClassDescription("This class defines the mass flux.");
  params.addRequiredParam<MaterialPropertyName>("mass_flux", "The mass flux name");
  params.addRequiredParam<MaterialPropertyName>("mobility", "The mobility of the species");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature for thermal diffusion");
  params.addRequiredCoupledVar("concentration", "The concentration of the chemical species");
  params.addRequiredCoupledVar("reference_concentration", "The reference concentration");
  params.addCoupledVar("additional_chemical_potential",
                       "Other chemical potential, e.g. the mechanical chemical potential for "
                       "stress-assisted diffusion");
  return params;
}

MassDiffusion::MassDiffusion(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _j(declareADProperty<RealVectorValue>("mass_flux")),
    _M(getADMaterialProperty<Real>("mobility")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _grad_T(adCoupledGradient("temperature")),
    _c(adCoupledValue("concentration")),
    _c0(coupledValue("reference_concentration")),
    _grad_c(adCoupledGradient("concentration")),
    _grad_mu(isParamValid("additional_chemical_potential")
                 ? &adCoupledGradient("additional_chemical_potential")
                 : nullptr)
{
}

void
MassDiffusion::computeQpProperties()
{
  /// Base mass flux
  _j[_qp] = -_M[_qp] * _R * _T[_qp] / _c[_qp] * _grad_c[_qp];

  /// Thermal diffusion
  _j[_qp] += -_M[_qp] * _R * std::log(_c[_qp] / _c0[_qp]) * _grad_T[_qp];

  /// Stress assisted diffusion
  if (_grad_mu)
    _j[_qp] += -_M[_qp] * (*_grad_mu)[_qp];
}
