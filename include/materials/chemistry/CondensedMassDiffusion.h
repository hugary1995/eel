#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "MathUtils.h"

class CondensedMassDiffusion : public DerivativeMaterialInterface<Material>
{
public:
  typedef Eigen::Matrix<ADReal, Eigen::Dynamic, 1> ADRealEigenVector;
  typedef Eigen::Matrix<ADReal, Eigen::Dynamic, Eigen::Dynamic> ADRealEigenMatrix;

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

  /// Number of basis functions
  const unsigned int _q;

private:
  ADRealEigenVector basisFunctions(const Point & q_point) const;
  ADRealEigenMatrix basisFunctionGradients(const Point & q_point) const;
};
