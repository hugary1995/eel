#pragma once

#include "ThermodynamicForce.h"

/**
 * This class computes the electric displacement associated with given energy densities for a given
 * species.
 */
class ElectricDisplacement : public ThermodynamicForce
{
public:
  static InputParameters validParams();

  ElectricDisplacement(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// The electric displacement
  ADMaterialProperty<RealVectorValue> & _D;

  /// Name of the electric potential
  const VariableName _Phi_name;

  /// Equilibrium forces
  std::vector<const ADMaterialProperty<RealVectorValue> *> _d_psi_d_grad_Phi;

  /// Viscous forces
  std::vector<const ADMaterialProperty<RealVectorValue> *> _d_psi_dis_d_grad_Phi_dot;
};
