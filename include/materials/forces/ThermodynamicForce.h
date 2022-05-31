// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "EelUtils.h"

template <typename T>
class ThermodynamicForce : public DerivativeMaterialInterface<Material>
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

  /// Equilibrium forces, i.e. derivative of the energy density w.r.t. the state variable
  std::vector<const ADMaterialProperty<T> *> _d_psi_d_s;

  /// The multiplication factor
  const Real _factor;
};
