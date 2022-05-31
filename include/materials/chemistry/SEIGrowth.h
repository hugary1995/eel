// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "InterfaceMaterial.h"
#include "ADSingleVariableReturnMappingSolution.h"

class SEIGrowth : public InterfaceMaterial, public ADSingleVariableReturnMappingSolution
{
public:
  static InputParameters validParams();
  SEIGrowth(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeQpProperties() override;

  virtual Real computeReferenceResidual(const ADReal &, const ADReal &);
  virtual ADReal computeResidual(const ADReal &, const ADReal &);
  virtual ADReal computeDerivative(const ADReal &, const ADReal &);

  ADMaterialProperty<Real> & _h;
  const MaterialProperty<Real> & _h_old;
  const ADMaterialProperty<Real> & _h0;

  const MaterialProperty<Real> & _j;
  const Real _Omega;
  const Real _hc;
  const ADMaterialProperty<Real> & _A;
  const Real _Q;
  const Real _R;
  const ADVariableValue & _T;
};
