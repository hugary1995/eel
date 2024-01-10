// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "VectorCurlCurl.h"

registerMooseObject("EelApp", VectorCurlCurl);

InputParameters
VectorCurlCurl::validParams()
{
  InputParameters params = VectorKernel::validParams();
  params.addClassDescription("Weak form term corresponding to $\\nabla \\times (p \\nabla \\times "
                             "\\vec{A})$.");
  params.addRequiredParam<MaterialPropertyName>(
      "prop", "Name of the material property to provide the multiplier");
  params.addParam<Real>("coefficient", 1.0, "Weak form coefficient (default = 1.0).");
  return params;
}

VectorCurlCurl::VectorCurlCurl(const InputParameters & parameters)
  : VectorKernel(parameters),
    _curl_test(_var.curlPhi()),
    _curl_phi(_assembly.curlPhi(_var)),
    _curl_u(_is_implicit ? _var.curlSln() : _var.curlSlnOld()),
    _prop(getMaterialProperty<Real>("prop")),
    _coeff(getParam<Real>("coefficient"))
{
}

Real
VectorCurlCurl::computeQpResidual()
{
  return _coeff * _prop[_qp] * _curl_u[_qp] * _curl_test[_i][_qp];
}

Real
VectorCurlCurl::computeQpJacobian()
{
  return _coeff * _prop[_qp] * _curl_phi[_j][_qp] * _curl_test[_i][_qp];
}
