// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "MassSource.h"

registerADMooseObject("EelApp", MassSource);

InputParameters
MassSource::validParams()
{
  InputParameters params = ThermodynamicForce<Real>::validParams();
  params.addClassDescription("This class computes the mass source associated with "
                             "given energy densities for a given species.");
  params.addRequiredParam<MaterialPropertyName>("mass_source", "Name of the mass source");
  params.addRequiredParam<MaterialPropertyName>("chemical_potential",
                                                "The chemical potential variable");
  return params;
}

MassSource::MassSource(const InputParameters & parameters) : ThermodynamicForce<Real>(parameters)
{
  const VariableName mu_name = getParam<MaterialPropertyName>("chemical_potential");

  // Get forces
  getThermodynamicForces(_d_psi_d_s, _psi_names, mu_name);

  // Declare the (total) thermodynamic force
  _force = &declareADProperty<Real>(getParam<MaterialPropertyName>("mass_source"));
}
