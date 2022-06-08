#include "Redox.h"

registerMooseObject("Stingray", Redox);

InputParameters
Redox::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription(
      "The Butler-Volmer condition across the electrode/electrolyte interface");
  params.addRequiredParam<RealVectorValue>(
      "exchange_current_density",
      "The exchange current density for the electrode/electrolyte interface");
  params.addRequiredParam<Real>("anodic_charge_transfer_coefficient",
                                "The dimensionless anodic charge transfer coefficient");
  params.addRequiredParam<Real>("cathodic_charge_transfer_coefficient",
                                "The dimensionless cathodic charge transfer coefficient");
  params.addRequiredParam<Real>("faraday_constant", "The Faraday's constant");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredParam<Real>("electric_conductivity", "The electric conductivity");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredCoupledVar("electric_potential", "The electric potential");
  params.addRequiredParam<Real>("penalty", "The penalty to enforce this interface condition");
  params.addRequiredParam<SubdomainName>("electrode_subdomain",
                                         "The subdomain name of the electrode");
  params.addRequiredParam<SubdomainName>("electrolyte_subdomain",
                                         "The subdomain name of the electrolyte");
  return params;
}

Redox::Redox(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _i0(getParam<RealVectorValue>("exchange_current_density")),
    _alpha_a(getParam<Real>("anodic_charge_transfer_coefficient")),
    _alpha_c(getParam<Real>("cathodic_charge_transfer_coefficient")),
    _F(getParam<Real>("faraday_constant")),
    _R(getParam<Real>("ideal_gas_constant")),
    _sigma(getParam<Real>("electric_conductivity")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _Phi(adCoupledValue("electric_potential")),
    _Phi_neighbor(adCoupledNeighborValue("electric_potential")),
    _grad_Phi(adCoupledGradient("electric_potential")),
    _grad_Phi_neighbor(adCoupledNeighborGradient("electric_potential")),
    _penalty(getParam<Real>("penalty")),
    _electrode_subdomain_id(_mesh.getSubdomainID(getParam<SubdomainName>("electrode_subdomain"))),
    _electrolyte_subdomain_id(
        _mesh.getSubdomainID(getParam<SubdomainName>("electrolyte_subdomain")))
{
}

ADReal
Redox::computeQpResidual(Moose::DGResidualType type)
{
  // Surface overpotential
  ADReal eta = 0;
  if (_current_elem->subdomain_id() == _electrode_subdomain_id &&
      _neighbor_elem->subdomain_id() == _electrolyte_subdomain_id)
    eta = _Phi[_qp] - _Phi_neighbor[_qp];
  else if (_current_elem->subdomain_id() == _electrolyte_subdomain_id &&
           _neighbor_elem->subdomain_id() == _electrode_subdomain_id)
    eta = _Phi_neighbor[_qp] - _Phi[_qp];
  else
    mooseError("Internal error");

  // Current density
  ADReal T = (_T[_qp] + _T_neighbor[_qp]) / 2;
  ADReal coef = _F / _R / T * eta;
  ADRealVectorValue i = _i0 * (std::exp(_alpha_a * coef) - std::exp(-_alpha_c * coef));

  // residual
  ADReal r = _sigma * _grad_Phi[_qp] * _normals[_qp] - i * _normals[_qp];
  ADReal rn = -(_sigma * _grad_Phi_neighbor[_qp] * _normals[_qp] - i * _normals[_qp]);

  switch (type)
  {
    case Moose::Element:
      return _test[_i][_qp] * _penalty * r;

    case Moose::Neighbor:
      return _test_neighbor[_i][_qp] * _penalty * rn;
  }

  return 0;
}
