#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialPropertyNameInterface.h"

/**
 * This class computes the elastic energy density and the corresponding thermodynamic forces. In
 * this app, we assume the elastic energy density depends on at least the deformation gradient and
 * the concentrations.
 */
class ElasticEnergyDensityBase : public Material,
                                 public BaseNameInterface,
                                 public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  ElasticEnergyDensityBase(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// Compute the elastic energy density
  virtual ADReal computeQpElasticEnergyDensity() const = 0;

  /// Compute the \frac{\partial \psi^e}{\partial F_m}
  virtual ADRankTwoTensor computeQpDElasticEnergyDensityDMechanicalDeformationGradient() = 0;

  /// Inverse of the total eigen deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fg_inv;

  /// Mechanical deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fm;

  /// Name of the elastic energy density
  const MaterialPropertyName _psi_name;

  /// The elastic energy density
  ADMaterialProperty<Real> & _psi;

  /// Derivative of the elastic energy density w.r.t. the deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_d_F;

  /// Derivative of the elastic energy density w.r.t. the mechanical deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_d_Fm;
};
