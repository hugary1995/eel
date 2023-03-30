#include "GBCavitation.h"

registerMooseObject("EelApp", GBCavitation);

InputParameters
GBCavitation::validParams()
{
  InputParameters params = ADCZMComputeLocalTractionTotalBase::validParams();
  params.addClassDescription("Grain boundary cavitation model");
  params.addRequiredCoupledVar("reference_concentration",
                               "The reference concentration at which no swelling occurs");
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

  return params;
}

GBCavitation::GBCavitation(const InputParameters & parameters)
  : ADCZMComputeLocalTractionTotalBase(parameters),
    _czm_total_rotation(getADMaterialProperty<RankTwoTensor>("czm_total_rotation")),
    _normals(_assembly.normals()),
    _c(adCoupledValue("concentration")),
    _c_neighbor(adCoupledNeighborValue("concentration")),
    _c_ref(adCoupledValue("reference_concentration")),
    _c_ref_neighbor(adCoupledNeighborValue("reference_concentration")),
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
    _j(declareADProperty<Real>("cavity_flux")),
    _m(declareADProperty<Real>("cavity_nucleation_rate")),
    _d(declareADProperty<Real>("damage")),
    _d_old(getMaterialPropertyOld<Real>("damage")),
    _D(declareADProperty<Real>("damage_driving_force")),
    _D_old(getMaterialPropertyOld<Real>("damage_driving_force"))
{
}

void
GBCavitation::initQpStatefulProperties()
{
  ADCZMComputeLocalTractionTotalBase::initQpStatefulProperties();

  _d[_qp] = 0;
  _D[_qp] = 0;
}

void
GBCavitation::computeInterfaceTraction()
{
  // total displacement jump
  ADRealVectorValue ju = _interface_displacement_jump[_qp];

  // local normal
  ADRealVectorValue n = _czm_total_rotation[_qp].transpose() * _normals[_qp];

  // cavity displacement jump
  ADRealVectorValue uc = _eta[_qp] * _Omega * (_c[_qp] - _c_ref[_qp]) * n;
  ADRealVectorValue uc_neighbor =
      _eta_neighbor[_qp] * _Omega * (_c_neighbor[_qp] - _c_ref_neighbor[_qp]) * (-n);
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
  _D[_qp] = 0.5 * (C * jue_active / _w) * jue_active / _w;

  // damage (with irreversibility)
  if (_D_old[_qp] < _Gc[_qp])
    _d[_qp] = 0;
  else
  {
    _d[_qp] = 1 - _Gc[_qp] / _D_old[_qp];
    _d[_qp] = std::max(_d[_qp], _d_old[_qp]);
  }

  // damage degradation
  ADReal g = (1 - _d[_qp]) * (1 - _d[_qp]);

  // local traction
  _interface_traction[_qp] = g * C * jue_active / _w + C * jue_inactive / _w;

  // cavity flux
  ADReal mu = _R * _T[_qp] * std::log(_c[_qp] / _c_ref[_qp]);
  ADReal mu_neighbor = _R * _T_neighbor[_qp] * std::log(_c_neighbor[_qp] / _c_ref_neighbor[_qp]);
  _j[_qp] = -_M[_qp] * (mu_neighbor - mu) / _w;

  // cavity nucleation rate
  ADReal tn = _interface_traction[_qp] * n;
  ADReal m = tn > 0 ? g * tn * _Nr[_qp] * std::exp(-_Q / _R / _T[_qp]) : 0;
  ADReal m_neighbor = tn > 0 ? g * tn * _Nr[_qp] * std::exp(-_Q / _R / _T_neighbor[_qp]) : 0;
  _m[_qp] = m + m_neighbor;
}
