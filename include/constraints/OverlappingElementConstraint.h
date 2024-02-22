// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "ElemElemConstraint.h"
#include "OverlappingElementPairLocator.h"

class OverlappingElementConstraint : public ElemElemConstraint
{
public:
  static InputParameters validParams();

  OverlappingElementConstraint(const InputParameters & parameters);

  virtual void initialSetup() override;

protected:
  const SubdomainID _primary;
  std::vector<SubdomainID> _secondary;
};
