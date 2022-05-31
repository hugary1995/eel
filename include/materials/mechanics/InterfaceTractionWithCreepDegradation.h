// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "ADCZMComputeLocalTractionTotalBase.h"
#include "ADSingleVariableReturnMappingSolution.h"

class InterfaceTractionWithCreepDegradation : public ADCZMComputeLocalTractionTotalBase,
                                              public ADSingleVariableReturnMappingSolution
{
public:
  static InputParameters validParams();
  InterfaceTractionWithCreepDegradation(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeInterfaceTraction() override;

  ADReal initialGuess(const ADReal &) override;
  Real computeReferenceResidual(const ADReal &, const ADReal &) override;
  ADReal computeResidual(const ADReal &, const ADReal &) override;
  ADReal computeDerivative(const ADReal &, const ADReal &) override;

  ADMaterialProperty<Real> & _D;
  const MaterialProperty<Real> & _D_old;
  ADMaterialProperty<Real> & _g;

  ADMaterialProperty<Real> & _juc;
  const MaterialProperty<Real> & _juc_old;

  const ADMaterialProperty<Real> & _Gc;
  ADMaterialProperty<Real> & _psi;
  const MaterialProperty<Real> & _psi_old;

  const ADMaterialProperty<Real> & _A;
  const Real _Q;
  const Real _R;
  const ADVariableValue & _T;
  const ADMaterialProperty<Real> & _Tn0;
  const Real _n;

  const ADMaterialProperty<Real> & _E;
  const ADMaterialProperty<Real> & _G;
  ADMaterialProperty<Real> & _Tn;

  const Real _eps;
};
