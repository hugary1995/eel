#include "ThermodynamicForce.h"

template <typename T>
InputParameters
ThermodynamicForce<T>::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += BaseNameInterface::validParams();
  params.addParam<std::vector<MaterialPropertyName>>("energy_densities",
                                                     "Vector of energy densities");
  params.addParam<std::vector<MaterialPropertyName>>("dissipation_densities",
                                                     "Vector of dissipation densities");
  params.addParam<MaterialPropertyName>(
      "heat", "The heat generation(source)/loss(sink) associated with this thermodynamic process.");
  params.addCoupledVar("temperature",
                       "The temperature variable. This is only required when you want to compute "
                       "the heat generation/loss due to thermal hardening/softening.");
  return params;
}

template <typename T>
ThermodynamicForce<T>::ThermodynamicForce(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    BaseNameInterface(parameters),
    _force(nullptr),
    _psi_names(prependBaseName(getParam<std::vector<MaterialPropertyName>>("energy_densities"))),
    _psi_dis_names(
        prependBaseName(getParam<std::vector<MaterialPropertyName>>("dissipation_densities"))),
    _d_psi_d_s(_psi_names.size()),
    _d_psi_dis_d_v(_psi_dis_names.size()),
    _heat(isParamValid("heat") ? &declareADProperty<Real>(prependBaseName("heat", true)) : nullptr),
    _temperature(isParamValid("temperature") ? &adCoupledValue("temperature") : nullptr)
{
}

template <typename T>
void
ThermodynamicForce<T>::getThermodynamicForces(std::vector<const ADMaterialProperty<T> *> & forces,
                                              const std::vector<MaterialPropertyName> & densities,
                                              const std::string var)
{
  for (auto i : make_range(densities.size()))
    forces[i] =
        &getDefaultMaterialPropertyByName<T, true>(derivativePropertyName(densities[i], {var}));
}

template <typename T>
void
ThermodynamicForce<T>::computeQpProperties()
{
  MathUtils::mooseSetToZero((*_force)[_qp]);

  // Equilibrium forces
  (*_force)[_qp] += computeQpThermodynamicForce(_d_psi_d_s);

  // Viscous forces
  (*_force)[_qp] += computeQpThermodynamicForce(_d_psi_dis_d_v);

  // Heat generation/loss
  if (_heat)
  {
    (*_heat)[_qp] = 0;
    // Heat due to viscous dissipation
    for (const auto & viscous_force : _d_psi_dis_d_v)
      (*_heat)[_qp] += MathUtils::inner((*viscous_force)[_qp], rate());
  }
}

template <typename T>
typename Moose::ADType<T>::type
ThermodynamicForce<T>::computeQpThermodynamicForce(
    const std::vector<const ADMaterialProperty<T> *> forces) const
{
  typename Moose::ADType<T>::type f;
  MathUtils::mooseSetToZero(f);
  for (const auto & force : forces)
    f += (*force)[_qp];
  return f;
}

template class ThermodynamicForce<Real>;
template class ThermodynamicForce<RealVectorValue>;
template class ThermodynamicForce<RankTwoTensor>;
