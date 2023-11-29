// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "ElementPairLocator.h"

#include "MooseMesh.h"
#include "Assembly.h"
#include "FEProblemBase.h"

class OverlappingElementPairLocator : public ElementPairLocator
{
public:
  OverlappingElementPairLocator(MooseMesh * mesh,
                                Assembly * assembly,
                                FEProblemBase * subproblem,
                                const SubdomainID primary,
                                const SubdomainID secondary);

  virtual void reinit() override;
  virtual void update() override { reinit(); }

protected:
  MooseMesh * _mesh;
  Assembly * _assembly;
  FEProblemBase * _fe_problem;
  const SubdomainID _primary;
  const SubdomainID _secondary;

private:
  std::list<std::pair<const Elem *, const Elem *>> _overlapping_elem_pairs;
};
