// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "Material.h"
#include "OverlappingElementPairLocator.h"

class EmbeddedMaterialUnsignedDistance : public Material
{
public:
  static InputParameters validParams();

  EmbeddedMaterialUnsignedDistance(const InputParameters & params);

  virtual void initialSetup() override
  {
    _oepl->reinit();
    reinitDistance();
  }

  virtual void meshChanged() override
  {
    _oepl->update();
    reinitDistance();
  }

protected:
  virtual void computeQpProperties() override;

  /// (Re)initialize the unsigned distance
  virtual void reinitDistance();

  /// The unsigned distance function
  MaterialProperty<Real> & _dist;

  /// The normal pointing to the closest projection
  MaterialProperty<RealVectorValue> & _normal;

  const SubdomainID _primary;
  const SubdomainID _secondary;

  /// The overlapping element locator
  std::unique_ptr<OverlappingElementPairLocator> _oepl;

  /// Map from (element) to (unsigned distance). This map should be reinit'ed on mesh change.
  std::map<dof_id_type, MooseArray<Real>> _dist_data;

  /// Map from (element) to (normal). This map should be reinit'ed on mesh change.
  std::map<dof_id_type, MooseArray<RealVectorValue>> _normal_data;
};
