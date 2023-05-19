#include "GBCavitationTest.h"

registerMooseObject("EelApp", GBCavitation);

InputParameters
GBCavitationTest::validParams()
{
  InputParameters params = ADCZMComputeLocalTractionTotalBase::validParams();
  params.addClassDescription("Grain boundary cavitation model");
  params.addRequiredCoupledVar("reference_concentration",
                               "The reference concentration at which no swelling occurs");
  params.addRequiredParam<MaterialPropertyName>("reference_chemical_potential",
                                                "reference chemical potential");
  params.addRequiredParam<MaterialPropertyName>("swelling_coefficient", "The swelling coefficient");
  params.addRequiredParam<Real>("molar_volume", "The molar volume of the chemical species");
  params.addRequiredParam<MaterialPropertyName>("normal_stiffness",
                                                "Interface stiffness in the normal direction");
  params.addRequiredParam<MaterialPropertyName>("tangential_stiffness",
                                                "Interface stiffness in the tangential direction");
  params.addRequiredParam<Real>("interface_width",
                                "A fictitious interface width for scaling purposes");
  params.addRequiredCoupledVar("concentration", "Concentration of the cavity");
  params.addRequiredParam<Real>("ideal_gas_constant", "The ideal gas constant");
  params.addRequiredCoupledVar("temperature", "The temperature");
  params.addRequiredParam<MaterialPropertyName>(
      "critical_energy_release_rate", "Critical energy release rate of the interface to debond");
  params.addRequiredParam<MaterialPropertyName>("damage", "Name of the interface damage");
  params.addRequiredParam<Real>("activation_energy",
                                "Activation energy for grain boundary void nucleation");
  params.addRequiredParam<MaterialPropertyName>("reference_nucleation_rate",
                                                "Reference void nucleation rate");
  params.addRequiredParam<MaterialPropertyName>(
      "mobility",
      "Mobility of the grain boundary cavity (its ability to travel across the interface)");
  params.addRequiredParam<MaterialPropertyName>("cavity_flux", "Name of the cavity flux");
  params.addRequiredParam<MaterialPropertyName>("cavity_nucleation_rate",
                                                "Name of the cavity nucleation rate");
  params.addParam<Real>("residual_stiffness", 1e-6, "residual stiffness when fully damaged");

  return params;
}

GBCavitationTest::GBCavitationTest(const InputParameters & parameters)
  : ADCZMComputeLocalTractionTotalBase(parameters),
    _czm_total_rotation(getADMaterialProperty<RankTwoTensor>("czm_total_rotation")),
    _normals(_assembly.normals()),
    _c(adCoupledValue("concentration")),
    _c_var(getVar("concentration", 0)), // change to a moose varible
    _c_neighbor(adCoupledNeighborValue("concentration")),
    _c_ref(adCoupledValue("reference_concentration")),
    _c_ref_neighbor(adCoupledNeighborValue("reference_concentration")),
    _mu0(getADMaterialProperty<Real>("reference_chemical_potential")),
    _mu0_neighbor(getNeighborADMaterialProperty<Real>("reference_chemical_potential")),
    // _mui_neighbor(getNeighborADMaterialProperty<Real>("interface_chemical_potential")),
    _eta(getADMaterialProperty<Real>("swelling_coefficient")),
    _eta_neighbor(getNeighborADMaterialProperty<Real>("swelling_coefficient")),
    _Omega(getParam<Real>("molar_volume")),
    _E(getADMaterialProperty<Real>("normal_stiffness")),
    _G(getADMaterialProperty<Real>("tangential_stiffness")),
    _w(getParam<Real>("interface_width")),
    _R(getParam<Real>("ideal_gas_constant")),
    _T(adCoupledValue("temperature")),
    _T_neighbor(adCoupledNeighborValue("temperature")),
    _Gc(getADMaterialProperty<Real>("critical_energy_release_rate")),
    _Nr(getADMaterialProperty<Real>("reference_nucleation_rate")),
    _Q(getParam<Real>("activation_energy")),
    _M(getADMaterialProperty<Real>("mobility")),
    // _j(declareADProperty<Real>("cavity_flux")), // TODO: change to vector
    _j(declareADProperty<RealVectorValue>("cavity_flux")),
    _mui(declareADProperty<Real>("interface_chemical_potential")), // add mui
    _grad_mui(declareADProperty<RealVectorValue>(
        "gradient_interface_chemical_potential")),                 // add grad mui
    _m(declareADProperty<Real>("cavity_nucleation_rate")),
    _d(declareADProperty<Real>("damage")),
    _d_old(getMaterialPropertyOld<Real>("damage")),
    _D(declareADProperty<Real>("damage_driving_force")),
    _D_old(getMaterialPropertyOld<Real>("damage_driving_force")),
    _g0(getParam<Real>("residual_stiffness")), // TODO: add test and grad(test) of c
    _test(_c_var->phi()),
    _grad_test(_c_var->gradPhi())
{
}

void
GBCavitationTest::initQpStatefulProperties()
{
  ADCZMComputeLocalTractionTotalBase::initQpStatefulProperties();

  _d[_qp] = 0;
  _D[_qp] = 0;
}

void
GBCavitationTest::computeInterfaceTraction()
{
  // total displacement jump
  ADRealVectorValue ju = _interface_displacement_jump[_qp];

  // local normal
  ADRealVectorValue n = _czm_total_rotation[_qp].transpose() * _normals[_qp];

  // cavity displacement jump
  ADRealVectorValue uc = _eta[_qp] * _Omega * (_c[_qp] - _c_ref[_qp]) * -n;
  ADRealVectorValue uc_neighbor =
      _eta_neighbor[_qp] * _Omega * (_c_neighbor[_qp] - _c_ref_neighbor[_qp]) * n;
  ADRealVectorValue juc = uc_neighbor - uc;

  // elastic displacement jump
  ADRealVectorValue jue = ju - juc;

  // tension-compression split
  ADRealVectorValue jue_active = jue;
  if (jue(0) < 0)
    jue(0) = 0;
  ADRealVectorValue jue_inactive = jue - jue_active;

  // interface stiffness
  ADRankTwoTensor C(_E[_qp], _G[_qp], _G[_qp], 0, 0, 0);

  // damage driving force
  _D[_qp] = 0.5 * (C * jue_active / _w) * jue_active / _w +
            0.5 * (_mu0[_qp] * _c[_qp] + _mu0_neighbor[_qp] * _c_neighbor[_qp]);

  // damage (with irreversibility)
  _d[_qp] = (1 - _g0) * _D_old[_qp] / ((1 - _g0) * _D_old[_qp] + 3 * _Gc[_qp]);
  _d[_qp] = std::max(_d[_qp], _d_old[_qp]);
  _d[_qp] = std::min(_d[_qp], 1.0);

  // damage degradation
  ADReal g = (1 - _d[_qp]) * (1 - _d[_qp]) * (1 - _g0) + _g0;

  // local traction
  _interface_traction[_qp] = g * C * jue_active / _w + g * C * jue_inactive / _w;

  // cavity flux
  // ADReal mu = g * _mu0[_qp] + _R * _T[_qp] * std::log(_c[_qp] / _c_ref[_qp]);

  // ADReal mu_neighbor = g * _mu0_neighbor[_qp] +
  //                      _R * _T_neighbor[_qp] * std::log(_c_neighbor[_qp] / _c_ref_neighbor[_qp]);
  // _j[_qp] = -_M[_qp] * (mu_neighbor - mu) / _w;

  // TODO: change mu: add term w*eta*Omega*vector(t)*vector(en)
  _mui[_qp] = _w * _eta[_qp] * _Omega * _interface_traction[_qp] * n + g * _mu0[_qp] +
              _R * _T[_qp] * std::log(_c[_qp] / _c_ref[_qp]);

  // TODO: compute grad(mu): see ChemicalPotential.C
  auto sol = L2Projection();

  for (_qp = 0; _qp < _qrule->n_points(); _qp++) // TODO: start from here
  {
    _grad_mui[_qp] = 0;
    for (unsigned int i = 0; i < _test.size(); i++)
    {
      _grad_mui[_qp] += _grad_test[i][_qp] * sol(i);
    }
  }

  // TODO: comput j here and grad(j) in GBCavitationTransport
  _j[_qp] = -_M[_qp] * _grad_mui[_qp];

  // cavity nucleation rate
  ADReal tn = _interface_traction[_qp] * n;
  ADReal m = tn > 0 ? tn * _Nr[_qp] * std::exp(-_Q / _R / _T[_qp]) : 0;
  ADReal m_neighbor = tn > 0 ? tn * _Nr[_qp] * std::exp(-_Q / _R / _T_neighbor[_qp]) : 0;
  _m[_qp] = m + m_neighbor;
}

EelUtils::ADRealEigenVector
GBCavitationTest::L2Projection()
{
  using EelUtils::ADRealEigenMatrix;
  using EelUtils::ADRealEigenVector;

  unsigned int n_local_dofs = _c_var->numberOfDofs();
  ADRealEigenVector re = ADRealEigenVector::Zero(n_local_dofs);
  ADRealEigenMatrix ke = ADRealEigenMatrix::Zero(n_local_dofs, n_local_dofs);

  // Construct the local L2 projection
  for (unsigned int i = 0; i < _test.size(); i++)
    for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    {
      Real t = _JxW[_qp] * _coord[_qp] * _test[i][_qp];
      re(i) += t * _mui[_qp];
      for (unsigned int j = 0; j < _test.size(); j++)
        ke(i, j) += t * _test[j][_qp];
    }

  return ke.ldlt().solve(re);
}
