#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "DerivativeMaterialInterface.h"

/**
 * This class computes the mass source associated with given energy densities for a given species.
 */
class MassSource : public DerivativeMaterialInterface<Material>, public BaseNameInterface
{
public:
  static InputParameters validParams();

  MassSource(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The mass source
  ADMaterialProperty<Real> & _mu;

  /// Name of the concentration variable
  const VariableName _c_name;

  /// @{ Energy densities
  std::vector<MaterialPropertyName> _psi_names;
  std::vector<const ADMaterialProperty<Real> *> _d_psi_d_c;
  /// @}
};
