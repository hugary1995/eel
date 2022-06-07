#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the mass source associated with given energy densities for a given species.
 */
class MassSource : public ThermodynamicForce
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

  /// Equilibrium forces
  std::vector<const ADMaterialProperty<Real> *> _d_psi_d_c;

  /// Viscous forces
  std::vector<const ADMaterialProperty<Real> *> _d_psi_dis_d_c_dot;
};
