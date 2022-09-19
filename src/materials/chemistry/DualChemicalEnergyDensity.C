#include "DualChemicalEnergyDensity.h"

template <bool condensed>
InputParameters
DualChemicalEnergyDensityTempl<condensed>::validParams()
{
  InputParameters params = DualChemicalEnergyDensityBase<condensed>::validParams();
  params.addClassDescription(
      "This class computes the dual chemical energy density and its corresponding "
      "thermodynamic forces. We assume the dual chemical energy density depends "
      "on the gradient of chemical potential.");
  params.addRequiredParam<MaterialPropertyName>("dual_chemical_energy_density",
                                                "Name of the dual chemical energy density");
  return params;
}

template <bool condensed>
DualChemicalEnergyDensityTempl<condensed>::DualChemicalEnergyDensityTempl(
    const InputParameters & parameters)
  : DualChemicalEnergyDensityBase<condensed>(parameters),
    _energy_name(this->template getParam<MaterialPropertyName>("dual_chemical_energy_density")),
    _zeta(this->template declareADProperty<Real>(_energy_name)),
    _d_zeta_d_grad_mu(this->template declarePropertyDerivative<RealVectorValue, true>(
        _energy_name, "∇" + _mu_name))
{
}

template class DualChemicalEnergyDensityTempl<false>;
template class DualChemicalEnergyDensityTempl<true>;
