#pragma once

#include "Material.h"
#include "EelUtils.h"
#include <Eigen/Dense>

class GBChemicalPotentialGradient : public Material
{
public:
  static InputParameters validParams();

  GBChemicalPotentialGradient(const InputParameters & parameters);

  void computeProperties() override;

protected:
  /// Concentration
  const MooseVariable * _c_var;

  /// the current test function
  const VariableTestValue & _test;

  /// gradient of the test function
  const VariableTestGradient & _grad_test;

  /// mobility
  const ADMaterialProperty<Real> & _Mi;

  /// chemical potential
  const ADMaterialProperty<Real> & _mui;

  /// chemical potential gradient
  ADMaterialProperty<RealVectorValue> & _grad_mui;

  /// cavity flux
  ADMaterialProperty<RealVectorValue> & _ji;

private:
  EelUtils::ADRealEigenVector L2Projection();
};
