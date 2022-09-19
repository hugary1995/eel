#pragma once

#include "Material.h"
#include "DualChemicalEnergyDensity.h"

template <bool condensed>
class MassDiffusionTempl : public DualChemicalEnergyDensityTempl<condensed>
{
public:
  static InputParameters validParams();

  MassDiffusionTempl(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// The mobility
  const ADMaterialProperty<Real> & _M;

  using DualChemicalEnergyDensityTempl<condensed>::_qp;
  using DualChemicalEnergyDensityTempl<condensed>::_grad_mu;
  using DualChemicalEnergyDensityTempl<condensed>::_zeta;
  using DualChemicalEnergyDensityTempl<condensed>::_d_zeta_d_grad_mu;
};

typedef MassDiffusionTempl<false> MassDiffusion;
typedef MassDiffusionTempl<true> CondensedMassDiffusion;
