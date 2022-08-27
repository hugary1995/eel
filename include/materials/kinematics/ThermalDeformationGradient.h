#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "Function.h"
#include "DerivativeMaterialInterface.h"

class ThermalDeformationGradient : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  ThermalDeformationGradient(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Name of the thermal deformation gradient
  const MaterialPropertyName _Ft_name;

  // The thermal deformation gradient
  ADMaterialProperty<RankTwoTensor> & _Ft;

  /// Temperature variable name
  const VariableName _T_name;

  // The current temperature
  const ADVariableValue & _T;

  // The reference temperature
  const VariableValue & _T_ref;

  // The thermal expansion coefficient
  const ADMaterialProperty<Real> & _alpha_t;

  /// Derivative of the thermal deformation gradient w.r.t. the log temperature
  ADMaterialProperty<RankTwoTensor> & _d_Ft_d_lnT;
};
