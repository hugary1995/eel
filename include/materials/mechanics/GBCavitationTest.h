#pragma once

#include "ADCZMComputeLocalTractionTotalBase.h"
#include "EelUtils.h"

class GBCavitationTest : public ADCZMComputeLocalTractionTotalBase
{
public:
  static InputParameters validParams();
  GBCavitationTest(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;

  void computeInterfaceTraction() override;

  const ADMaterialProperty<RankTwoTensor> & _czm_total_rotation;

  const MooseArray<Point> & _normals;

  const ADVariableValue & _c;
  const MooseVariable * _c_var;
  const ADVariableValue & _c_neighbor;

  const ADVariableValue & _c_ref;
  const ADVariableValue & _c_ref_neighbor;

  const ADMaterialProperty<Real> & _mu0;
  const ADMaterialProperty<Real> & _mu0_neighbor;

  const ADMaterialProperty<Real> & _eta;
  const ADMaterialProperty<Real> & _eta_neighbor;

  const Real _Omega;

  const ADMaterialProperty<Real> & _E;

  const ADMaterialProperty<Real> & _G;

  const Real _w;

  const Real _R;

  const ADVariableValue & _T;
  const ADVariableValue & _T_neighbor;

  const ADMaterialProperty<Real> & _Gc;

  const ADMaterialProperty<Real> & _Nr;

  const Real & _Q;

  ADMaterialProperty<Real> & _mui;

  ADMaterialProperty<Real> & _mi;

  ADMaterialProperty<Real> & _d;

  const MaterialProperty<Real> & _d_old;

  ADMaterialProperty<Real> & _D;

  const MaterialProperty<Real> & _D_old;

  const Real _g0;

  const Real _p;
};
