//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ElectricDisplacement.h"

registerADMooseObject("StingrayApp", ElectricDisplacement);

InputParameters
ElectricDisplacement::validParams()
{
  InputParameters params = ThermodynamicForce::validParams();
  params.addClassDescription("This class computes the electric displacement associated with "
                             "given energy densities.");
  params.addRequiredParam<MaterialPropertyName>("electric_displacement",
                                                "Name of the electric displacement");
  params.addRequiredCoupledVar("electric_potential", "The electric potential variable");
  return params;
}

ElectricDisplacement::ElectricDisplacement(const InputParameters & parameters)
  : ThermodynamicForce(parameters),
    _D(declareADProperty<RealVectorValue>(prependBaseName("electric_displacement", true))),
    _Phi_name(getVar("electric_potential", 0)->name()),
    _d_psi_d_grad_Phi(_psi_names.size()),
    _d_psi_dis_d_grad_Phi_dot(_psi_dis_names.size())
{
  // Get thermodynamic forces
  for (auto i : make_range(_psi_names.size()))
    _d_psi_d_grad_Phi[i] = &getDefaultMaterialPropertyByName<RealVectorValue, true>(
        derivativePropertyName(_psi_names[i], {"grad_" + _Phi_name}));
  for (auto i : make_range(_psi_dis_names.size()))
    _d_psi_dis_d_grad_Phi_dot[i] = &getDefaultMaterialPropertyByName<RealVectorValue, true>(
        derivativePropertyName(_psi_dis_names[i], {"grad_" + _Phi_name + "_dot"}));
}

void
ElectricDisplacement::computeQpProperties()
{
  _D[_qp].zero();
  for (const auto & d_psi_d_grad_Phi : _d_psi_d_grad_Phi)
    _D[_qp] += (*d_psi_d_grad_Phi)[_qp];
  for (const auto & d_psi_dis_d_grad_Phi_dot : _d_psi_dis_d_grad_Phi_dot)
    _D[_qp] += (*d_psi_dis_d_grad_Phi_dot)[_qp];
}
