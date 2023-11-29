// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "RelationshipManager.h"
#include "SystemBase.h"
#include "Assembly.h"

class GhostOverlappingElements : public RelationshipManager
{
public:
  GhostOverlappingElements(const InputParameters &);

  GhostOverlappingElements(const GhostOverlappingElements & others);

  static InputParameters validParams();

  void operator()(const MeshBase::const_element_iterator & range_begin,
                  const MeshBase::const_element_iterator & range_end,
                  processor_id_type p,
                  map_type & coupled_elements) override;

  std::unique_ptr<GhostingFunctor> clone() const override
  {
    return std::make_unique<GhostOverlappingElements>(*this);
  }

  std::string getInfo() const override;

  virtual bool operator>=(const RelationshipManager & other) const override;

protected:
  const SubdomainName _primary;
  const SubdomainName _secondary;
};
