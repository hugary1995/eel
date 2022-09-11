#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "MathUtils.h"
#include "EelUtils.h"
#include <Eigen/Dense>

class CondensedMassDiffusion : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  CondensedMassDiffusion(const InputParameters & parameters);

  void computeProperties() override;

protected:
  /// Mass flux
  ADMaterialProperty<RealVectorValue> & _j;

  /// The mobility
  const ADMaterialProperty<Real> & _M;

  /// Energy names
  const std::vector<MaterialPropertyName> _psi_names;

  /// Energy derivatives
  std::vector<const ADMaterialProperty<Real> *> _d_psi_d_c_dot;

  /// Concentration
  const MooseVariable * _c_var;

  /// The multi-index table
  const std::vector<std::vector<unsigned int>> _multi_index;

  /// Number of basis functions for patch recovery
  unsigned int _q;

  /// the current test function
  const VariableTestValue & _test;

  /// gradient of the test function
  const VariableTestGradient & _grad_test;
};
