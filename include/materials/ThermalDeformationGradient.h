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
  virtual void initQpStatefulProperties() override;

  virtual void computeQpProperties() override;

  // The thermal eigen deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Ft;
  const MaterialProperty<RankTwoTensor> & _Ft_old;

  // The instantaneous thermal expansion coefficient
  const Function & _alpha;

  // The current temperature
  const ADVariableValue & _T;

  // The temperature at the beginning of this time step
  const VariableValue & _T_old;

  // The reference temperature
  const VariableValue & _T_ref;

  /// Indicates whether we are on the first step, avoiding false positives when restarting
  bool & _step_one;
};
