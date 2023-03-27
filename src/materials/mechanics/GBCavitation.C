#include "GBCavitation.h"

registerMooseObject("EelApp", GBCavitation);

InputParameters
GBCavitation::validParams()
{
  InputParameters params = CZMComputeLocalTractionTotalBase::validParams();
  params.addClassDescription("Grain boundary cavitation model");
  params.addRequiredParam<MaterialPropertyName>("normal_stiffness",
                                                "Interface stiffness in the normal direction");
  params.addRequiredParam<MaterialPropertyName>("tangential_stiffness",
                                                "Interface stiffness in the tangential direction");
  params.addRequiredParam<Real>("interface_width",
                                "A fictitious interface width for scaling purposes");
  params.addRequiredParam<MaterialPropertyName>("reference_chemical_potential",
                                                "Reference chemical potential");
  params.addRequiredCoupledVar("concentration", "Concentration of the cavity");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredParam<MaterialPropertyName>(
      "critical_energy_release_rate", "Critical energy release rate of the interface to debond");

  return params;
}

GBCavitation::GBCavitation(const InputParameters & parameters)
  : CZMComputeLocalTractionTotalBase(parameters),
    _E(getADMaterialProperty<Real>("normal_stiffness")),
    _G(getADMaterialProperty<Real>("tangential_stiffness")),
    _w(getParam<Real>("interface_width")),
    _mu0(getADMaterialProperty<Real>("reference_chemical_potential")),
    _c(adCoupledValue("concentration")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _Gc(getADMaterialProperty<Real>("critical_energy_release_rate"))
{
}

void
GBCavitation::initQpStatefulProperties()
{
  CZMComputeLocalTractionTotalBase::initQpStatefulProperties();

  _d[_qp] = 0.0;
}

void
GBCavitation::computeInterfaceTraction()
{
}
