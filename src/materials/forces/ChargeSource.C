#include "ChargeSource.h"

registerADMooseObject("StingrayApp", ChargeSource);

InputParameters
ChargeSource::validParams()
{
  InputParameters params = ThermodynamicForce<Real>::validParams();
  params.addClassDescription("This class computes the charge source associated with "
                             "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("charge_source", "Name of the charge source");
  params.addRequiredCoupledVar("electric_potential", "The electric potential variable");
  return params;
}

ChargeSource::ChargeSource(const InputParameters & parameters)
  : ThermodynamicForce<Real>(parameters),
    _Phi_name(getVar("electric_potential", 0)->name()),
    _Phi_dot(_heat ? &adCoupledDot("electric_potential") : nullptr)
{
  // Get equilibrium forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, _Phi_name);

  // Get viscous forces
  getThermodynamicForces(_d_psi_dis_d_v, _psi_dis_names, _Phi_name + "_dot");

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<Real>(prependBaseName("charge_source", true));
}
