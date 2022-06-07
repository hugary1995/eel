#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "DerivativeMaterialInterface.h"

/**
 * This is the base class for all thermodynamic forces
 */
class ThermodynamicForce : public DerivativeMaterialInterface<Material>, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ThermodynamicForce(const InputParameters & parameters);

protected:
  std::vector<MaterialPropertyName> _psi_names;
};
