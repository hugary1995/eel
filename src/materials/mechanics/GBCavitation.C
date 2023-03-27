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
  : CZMComputeLocalTractionTotalBase(parameters)
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
