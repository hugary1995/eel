#include "VectorComponents.h"

registerMooseObject("EelApp", VectorComponents);

InputParameters
VectorComponents::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredParam<MaterialPropertyName>("v", "The vector material property");
  return params;
}

VectorComponents::VectorComponents(const InputParameters & parameters)
  : Material(parameters),
    _v_name(getParam<MaterialPropertyName>("v")),
    _x_comp(declareADProperty<Real>(_v_name + "_x")),
    _y_comp(declareADProperty<Real>(_v_name + "_y")),
    _z_comp(declareADProperty<Real>(_v_name + "_z")),
    _v(getADMaterialProperty<RealVectorValue>("v"))
{
}

void
VectorComponents::computeQpProperties()
{
  _x_comp[_qp] = _v[_qp](0);
  _y_comp[_qp] = _v[_qp](1);
  _z_comp[_qp] = _v[_qp](2);
}
