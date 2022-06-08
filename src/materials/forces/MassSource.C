#include "MassSource.h"

registerADMooseObject("StingrayApp", MassSource);

InputParameters
MassSource::validParams()
{
  InputParameters params = ThermodynamicForce<Real>::validParams();
  params.addClassDescription("This class computes the mass source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_source", "Name of the mass source");
  params.addRequiredCoupledVar("concentration", "The concentration variable");
  return params;
}

MassSource::MassSource(const InputParameters & parameters)
  : ThermodynamicForce<Real>(parameters),
    _c_name(getVar("concentration", 0)->name()),
    _c_dot(_heat ? &adCoupledDot("concentration") : nullptr)
{
  // Get equilibrium forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, _c_name);

  // Get viscous forces
  getThermodynamicForces(_d_psi_dis_d_v, _psi_dis_names, _c_name + "_dot");

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<Real>(prependBaseName("mass_source", true));
}
