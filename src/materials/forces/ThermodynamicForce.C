//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ThermodynamicForce.h"

InputParameters
ThermodynamicForce::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addRequiredParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                             "Vector of energy densities");
  return params;
}

ThermodynamicForce::ThermodynamicForce(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    _psi_names(prependBaseName(getParam<std::vector<MaterialPropertyName>>("energy_densities")))
{
  for (const auto & psi_name : _psi_names)
    if (!hasADMaterialProperty<Real>(psi_name))
      mooseWarning("The energy density '",
                   psi_name,
                   "' does not exist. The material '",
                   name(),
                   "' only needs its derivatives, but this may indicate a typo in the input file.");
}
