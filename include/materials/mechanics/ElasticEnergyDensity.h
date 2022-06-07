#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"

/**
 * This class computes the elastic energy density and the corresponding thermodynamic forces. In
 * this app, we assume the elastic energy density depends on at least the deformation gradient and
 * the concentrations.
 */
class ElasticEnergyDensity : public DerivativeMaterialInterface<Material>, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ElasticEnergyDensity(const InputParameters & parameters);

  virtual void computeQpProperties() override;

protected:
  /// Compute the elastic energy density
  virtual ADReal computeQpElasticEnergyDensity() const = 0;

  /// Compute \frac{\partial \psi^e}{\partial F_m}
  virtual ADRankTwoTensor computeQpDElasticEnergyDensityDMechanicalDeformationGradient() = 0;

  /// Mechanical deformation gradient
  const ADMaterialProperty<RankTwoTensor> & _Fm;

  /// Names of the concentration variables
  std::vector<VariableName> _c_names;

  /// Derivative of Fm w.r.t. F
  const ADMaterialProperty<RankFourTensor> & _d_Fm_d_F;

  /// Derivative of Fm w.r.t. Fs
  const ADMaterialProperty<RankFourTensor> & _d_Fm_d_Fs;

  /// Derivatives of Fs w.r.t. concentrations
  std::vector<const ADMaterialProperty<RankTwoTensor> *> _d_Fs_d_c;

  /// Name of the elastic energy density
  const MaterialPropertyName _psi_name;

  /// The elastic energy density
  ADMaterialProperty<Real> & _psi;

  /// Derivative of the elastic energy density w.r.t. the deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_d_F;

  /// Derivative of the elastic energy density w.r.t. the mechanical deformation gradient
  ADMaterialProperty<RankTwoTensor> & _d_psi_d_Fm;

  /// Derivative of the elastic energy density w.r.t. the concentrations
  std::vector<ADMaterialProperty<Real> *> _d_psi_d_c;
};
