#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the mass flux associated with given energy densities for a given species.
 */
class MassFlux : public ThermodynamicForce
{
public:
  static InputParameters validParams();

  MassFlux(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The mass flux
  ADMaterialProperty<RealVectorValue> & _J;

  /// Name of the concentration variable
  const VariableName _c_name;

  /// Energy densities
  std::vector<const ADMaterialProperty<RealVectorValue> *> _d_psi_d_grad_c;
};
