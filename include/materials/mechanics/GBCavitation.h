#pragma once

#include "ADCZMComputeLocalTractionTotalBase.h"

class GBCavitation : public ADCZMComputeLocalTractionTotalBase
{
public:
  static InputParameters validParams();
  GBCavitation(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;

  void computeInterfaceTraction() override;

  const ADMaterialProperty<RankTwoTensor> & _czm_total_rotation;

  const MooseArray<Point> & _normals;

  const ADVariableValue & _c;
  const ADVariableValue & _c_neighbor;

  const ADVariableValue & _c_ref;
  const ADVariableValue & _c_ref_neighbor;

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

  const ADMaterialProperty<Real> & _M;

  ADMaterialProperty<Real> & _j;

  ADMaterialProperty<Real> & _m;

  ADMaterialProperty<Real> & _d;

  const MaterialProperty<Real> & _d_old;

  ADMaterialProperty<Real> & _D;

  const MaterialProperty<Real> & _D_old;
};
