#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "DerivativeMaterialInterface.h"
#include "StingrayUtils.h"

/**
 * This is the base class for all thermodynamic forces
 */
template <typename T>
class ThermodynamicForce : public DerivativeMaterialInterface<Material>, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ThermodynamicForce(const InputParameters & parameters);

protected:
  virtual void getThermodynamicForces(std::vector<const ADMaterialProperty<T> *> & forces,
                                      const std::vector<MaterialPropertyName> & densities,
                                      const std::string var);

  virtual void computeQpProperties() override;

  virtual typename Moose::ADType<T>::type
  computeQpThermodynamicForce(const std::vector<const ADMaterialProperty<T> *> forces) const;

  /// The thermodynamic force
  ADMaterialProperty<T> * _force;

  /// Energy densities
  std::vector<MaterialPropertyName> _psi_names;

  /// Dissipation densities
  std::vector<MaterialPropertyName> _psi_dis_names;

  /// Equilibrium forces, i.e. derivative of the energy density w.r.t. the state variable
  std::vector<const ADMaterialProperty<T> *> _d_psi_d_s;

  /// Viscous forces, i.e. derivative of the dissipation density w.r.t. the generalized velocity
  std::vector<const ADMaterialProperty<T> *> _d_psi_dis_d_v;

  /// Heat source
  ADMaterialProperty<Real> * _heat;

  /// Temperature
  const ADVariableValue * _temperature;
};
