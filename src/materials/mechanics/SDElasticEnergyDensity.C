#include "SDElasticEnergyDensity.h"

registerMooseObject("EelApp", SDElasticEnergyDensity);

InputParameters
SDElasticEnergyDensity::validParams()
{
  InputParameters params = DerivativeMaterialInterface<Material>::validParams();
  params += ADSingleVariableReturnMappingSolution::validParams();

  params.addClassDescription("This class defines the small deformation elastic energy density.");
  params.addRequiredParam<MaterialPropertyName>("lambda", "Lame's first parameter");
  params.addRequiredParam<MaterialPropertyName>("shear_modulus", "The shear modulus");
  params.addRequiredParam<MaterialPropertyName>("strain", "The total strain");
  params.addRequiredParam<MaterialPropertyName>("mechanical_strain", "The mechanical strain");
  params.addRequiredParam<MaterialPropertyName>("elastic_strain", "The elastic strain");
  params.addRequiredParam<MaterialPropertyName>("plastic_strain", "The plastic strain");
  params.addRequiredParam<MaterialPropertyName>("equivalent_plastic_strain",
                                                "The equivalent plastic strain");
  params.addRequiredParam<MaterialPropertyName>("elastic_energy_density",
                                                "The elastic energy density");
  params.addRequiredParam<MaterialPropertyName>("swelling_strain", "The swelling strain");
  params.addRequiredParam<VariableName>("concentration", "The concentration");
  params.addRequiredParam<MaterialName>(
      "plastic_dissipation_material", "The material defining the plastic dissipation rate density");
  params.addRequiredParam<MaterialPropertyName>("plastic_power_density",
                                                "The plastic dissipation rate");
  params.addRequiredParam<Real>("creep_coefficient", "The creep rate coefficient");
  params.addRequiredParam<Real>("creep_exponent", "The creep rate exponent");
  return params;
}

SDElasticEnergyDensity::SDElasticEnergyDensity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    ADSingleVariableReturnMappingSolution(parameters),
    _lambda(getADMaterialProperty<Real>("lambda")),
    _G(getADMaterialProperty<Real>("shear_modulus")),
    _Em(getADMaterialProperty<RankTwoTensor>("mechanical_strain")),
    _E_dot(getADMaterialPropertyByName<RankTwoTensor>(
        "dot(" + getParam<MaterialPropertyName>("strain") + ")")),
    _Ee(declareADProperty<RankTwoTensor>("elastic_strain")),
    _Ep(declareADProperty<RankTwoTensor>("plastic_strain")),
    _Ep_old(getMaterialPropertyOld<RankTwoTensor>("plastic_strain")),
    _ep(declareADProperty<Real>("equivalent_plastic_strain")),
    _ep_old(getMaterialPropertyOld<Real>("equivalent_plastic_strain")),
    _ep_dot(declareADPropertyByName<Real>(
        getParam<MaterialPropertyName>("equivalent_plastic_strain") + "_dot")),
    _psi_dot(declareADProperty<Real>(
        "dot(" + getParam<MaterialPropertyName>("elastic_energy_density") + ")")),
    _d_psi_dot_d_E_dot(declarePropertyDerivative<RankTwoTensor, true>(
        "dot(" + getParam<MaterialPropertyName>("elastic_energy_density") + ")",
        "dot(" + getParam<MaterialPropertyName>("strain") + ")")),
    _d_psi_dot_d_c_dot(declarePropertyDerivative<Real, true>(
        "dot(" + getParam<MaterialPropertyName>("elastic_energy_density") + ")",
        "dot(" + getParam<VariableName>("concentration") + ")")),
    _d_es_d_c(getMaterialPropertyDerivative<Real, true>(
        "vol(" + getParam<MaterialPropertyName>("swelling_strain") + ")",
        getParam<VariableName>("concentration"))),
    _sigma_y(getMaterialPropertyDerivative<Real, true>(
        getParam<MaterialPropertyName>("plastic_power_density"),
        getParam<MaterialPropertyName>("equivalent_plastic_strain") + "_dot")),
    _d_sigma_y_d_ep(getMaterialPropertyDerivative<Real, true>(
        getParam<MaterialPropertyName>("plastic_power_density"),
        getParam<MaterialPropertyName>("equivalent_plastic_strain") + "_dot",
        getParam<MaterialPropertyName>("equivalent_plastic_strain"))),
    _A(getParam<Real>("creep_coefficient")),
    _n(getParam<Real>("creep_exponent"))
{
}

void
SDElasticEnergyDensity::initialSetup()
{
  _plastic_dissipation_material = &getMaterial("plastic_dissipation_material");
}

void
SDElasticEnergyDensity::initQpStatefulProperties()
{
  _Ep[_qp].zero();
  _ep[_qp] = 0;
}

void
SDElasticEnergyDensity::computeQpProperties()
{
  // Flow direction doesn't change over the step
  computeQpFlowDirection();

  // Return map
  ADReal delta_ep = 0;
  const auto phi = computeResidual(0, delta_ep);
  if (phi > 0)
    returnMappingSolve(0, delta_ep, _console);

  // Update stress
  _ep[_qp] = _ep_old[_qp] + delta_ep;
  _Ep[_qp] = _Ep_old[_qp] + delta_ep * _Np;
  _Ee[_qp] = _Em[_qp] - _Ep[_qp];
  computeQpStress();

  // Update energies
  computeQpEnergy();
}

void
SDElasticEnergyDensity::computeQpStress()
{
  _d_psi_dot_d_E_dot[_qp] =
      _lambda[_qp] * _Ee[_qp].trace() * ADRankTwoTensor::Identity() + 2 * _G[_qp] * _Ee[_qp];
}

void
SDElasticEnergyDensity::computeQpFlowDirection()
{
  // Assuming an elastic step
  _Ee[_qp] = _Em[_qp] - _Ep_old[_qp];
  computeQpStress();

  const auto stress = _d_psi_dot_d_E_dot[_qp];
  const auto stress_dev = stress.deviatoric();
  auto stress_dev_norm = stress_dev.doubleContraction(stress_dev);
  if (MooseUtils::absoluteFuzzyEqual(stress_dev_norm, 0))
    stress_dev_norm.value() = libMesh::TOLERANCE;
  stress_dev_norm = std::sqrt(1.5 * stress_dev_norm);
  _Np = 1.5 * stress_dev / stress_dev_norm;
}

void
SDElasticEnergyDensity::computeQpEnergy()
{
  _psi_dot[_qp] = _d_psi_dot_d_E_dot[_qp].doubleContraction(_E_dot[_qp]);
  _d_psi_dot_d_c_dot[_qp] = -_d_psi_dot_d_E_dot[_qp].trace() * _d_es_d_c[_qp];
  _plastic_dissipation_material->computePropertiesAtQp(_qp);
}

Real
SDElasticEnergyDensity::computeReferenceResidual(const ADReal &, const ADReal & delta_ep)
{
  _Ep[_qp] = _Ep_old[_qp] + delta_ep * _Np;
  _Ee[_qp] = _Em[_qp] - _Ep[_qp];
  computeQpStress();

  const auto stress = _d_psi_dot_d_E_dot[_qp];

  return raw_value(stress.doubleContraction(_Np));
}

ADReal
SDElasticEnergyDensity::computeResidual(const ADReal &, const ADReal & delta_ep)
{
  _ep[_qp] = _ep_old[_qp] + delta_ep;
  _ep_dot[_qp] = delta_ep / _dt;
  _plastic_dissipation_material->computePropertiesAtQp(_qp);

  _Ep[_qp] = _Ep_old[_qp] + delta_ep * _Np;
  _Ee[_qp] = _Em[_qp] - _Ep[_qp];
  computeQpStress();

  const auto stress = _d_psi_dot_d_E_dot[_qp];
  const auto effective_stress = stress.doubleContraction(_Np);
  const auto creep_rate = _A * std::pow(effective_stress / _sigma_y[_qp], _n);

  return creep_rate * _dt - delta_ep;
}

ADReal
SDElasticEnergyDensity::computeDerivative(const ADReal &, const ADReal & delta_ep)
{
  _ep[_qp] = _ep_old[_qp] + delta_ep;
  _plastic_dissipation_material->computePropertiesAtQp(_qp);

  _Ep[_qp] = _Ep_old[_qp] + delta_ep * _Np;
  _Ee[_qp] = _Em[_qp] - _Ep[_qp];
  computeQpStress();

  const auto stress = _d_psi_dot_d_E_dot[_qp];
  const auto effective_stress = stress.doubleContraction(_Np);
  const auto d_effective_stress_d_delta_ep = -3 * _G[_qp];
  const auto creep_rate = _A * std::pow(effective_stress / _sigma_y[_qp], _n);

  return _n / effective_stress * creep_rate * _dt * d_effective_stress_d_delta_ep - 1;
}
