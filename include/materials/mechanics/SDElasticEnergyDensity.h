#pragma once

#include "Material.h"
#include "ADRankTwoTensorForward.h"
#include "DerivativeMaterialInterface.h"
#include "ADSingleVariableReturnMappingSolution.h"

class SDElasticEnergyDensity : public DerivativeMaterialInterface<Material>,
                               public ADSingleVariableReturnMappingSolution
{
public:
  static InputParameters validParams();

  SDElasticEnergyDensity(const InputParameters & parameters);

  virtual void initialSetup();

protected:
  virtual void initQpStatefulProperties();
  virtual void computeQpProperties();
  virtual void computeQpStress();
  virtual void computeQpFlowDirection();
  virtual void computeQpEnergy();

  virtual Real computeReferenceResidual(const ADReal &, const ADReal &);
  virtual ADReal computeResidual(const ADReal &, const ADReal &);
  virtual ADReal computeDerivative(const ADReal &, const ADReal &);

  /// Lame's first parameter
  const ADMaterialProperty<Real> & _lambda;

  /// Shear modulus
  const ADMaterialProperty<Real> & _G;

  const ADMaterialProperty<RankTwoTensor> & _Em;
  const ADMaterialProperty<RankTwoTensor> & _E_dot;
  ADMaterialProperty<RankTwoTensor> & _Ee;
  ADMaterialProperty<RankTwoTensor> & _Ep;
  const MaterialProperty<RankTwoTensor> & _Ep_old;
  ADMaterialProperty<Real> & _ep;
  const MaterialProperty<Real> & _ep_old;
  ADMaterialProperty<Real> & _ep_dot;
  ADMaterialProperty<Real> & _psi_dot;
  ADMaterialProperty<RankTwoTensor> & _d_psi_dot_d_E_dot;
  ADMaterialProperty<Real> & _d_psi_dot_d_c_dot;
  const ADMaterialProperty<Real> & _d_es_d_c;
  const ADMaterialProperty<Real> & _sigma_y;
  const ADMaterialProperty<Real> & _d_sigma_y_d_ep;
  const Real _A;
  const Real _n;

  MaterialBase * _plastic_dissipation_material;

private:
  ADRankTwoTensor _Np;
};
