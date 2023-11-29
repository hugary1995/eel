// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "OverlappingElementConstraint.h"

InputParameters
OverlappingElementConstraint::validParams()
{
  InputParameters params = ElemElemConstraint::validParams();
  params.addRequiredParam<SubdomainName>("primary", "primary block id");
  params.addRequiredParam<SubdomainName>("secondary", "secondary block id");
  params.suppressParameter<unsigned int>("interface_id");

  params.addRelationshipManager("GhostOverlappingElements",
                                Moose::RelationshipManagerType::GEOMETRIC |
                                    Moose::RelationshipManagerType::ALGEBRAIC |
                                    Moose::RelationshipManagerType::COUPLING,
                                [](const InputParameters & obj_params, InputParameters & rm_params)
                                { rm_params.applyParameters(obj_params); });

  return params;
}

OverlappingElementConstraint::OverlappingElementConstraint(const InputParameters & parameters)
  : ElemElemConstraint(parameters),
    _primary(_mesh.getSubdomainID(getParam<SubdomainName>("primary"))),
    _secondary(_mesh.getSubdomainID(getParam<SubdomainName>("secondary")))
{
  auto oepl = std::make_shared<OverlappingElementPairLocator>(
      &_mesh, &_assembly, &_fe_problem, _primary, _secondary);
  oepl->reinit();
  _fe_problem.geomSearchData().addElementPairLocator(_interface_id, oepl);
}

void
OverlappingElementConstraint::initialSetup()
{
}
