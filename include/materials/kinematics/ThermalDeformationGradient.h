#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "Function.h"

/**
 * This class computes the thermal deformation gradient
 */
class ThermalDeformationGradient : public Material, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ThermalDeformationGradient(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  // The thermal eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Ft;

  // The instantaneous thermal expansion coefficient
  const Function & _alpha;

  // The current temperature
  const ADVariableValue & _T;

  // The reference temperature
  const VariableValue & _T_ref;
};
