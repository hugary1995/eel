// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "ElementPairLocator.h"

#include "MooseMesh.h"
#include "Assembly.h"
#include "FEProblemBase.h"

class MatrixFiberElementPairLocator : public ElementPairLocator
{
public:
  MatrixFiberElementPairLocator(MooseMesh * mesh,
                                Assembly * assembly,
                                FEProblemBase * feproblem,
                                const BoundaryID primary,
                                const SubdomainID secondary);

  virtual void reinit() override;
  virtual void update() override { reinit(); }
  virtual const std::vector<Point> & secondaryQPoints() const { return _secondary_qpoints; }

protected:
  const Elem * findPrimaryElem(const Point & p,
                               const std::unordered_set<dof_id_type> & elem_ids) const;
  void addElemPair(const Elem * secondary_elem,
                   const std::unordered_set<dof_id_type> & primary_elems);
  MooseMesh * _mesh;
  Assembly * _assembly;
  FEProblemBase * _fe_problem;
  const BoundaryID _primary;
  const SubdomainID _secondary;

private:
  std::list<std::pair<const Elem *, const Elem *>> _overlapping_elem_pairs;
  std::vector<Point> _secondary_qpoints;
};
