// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "MeshGenerator.h"
#include "libmesh/elem.h"

/*
 * A mesh generator to split a mesh by breaking all element-element interfaces on the specified
 * boundary (sideset)
 */
class BreakMeshBySideSet : public MeshGenerator
{
public:
  static InputParameters validParams();

  BreakMeshBySideSet(const InputParameters & parameters);

  std::unique_ptr<MeshBase> generate() override;

protected:
  void buildNodeToSideMap(MeshBase & mesh);
  void buildNodeToElemMap(MeshBase & mesh);

  void duplicateNodes(MeshBase & mesh) const;

  void duplicateNode(MeshBase & mesh, Elem * elem, const Node * node) const;

  /// The mesh to modify
  std::unique_ptr<MeshBase> & _input;

  // The boundary names
  const std::vector<BoundaryName> & _boundary_names;

  // The boundary IDs
  std::vector<BoundaryID> _boundaries;

  // Node to connected sides map
  std::map<Node *, std::vector<std::pair<Elem *, unsigned short int>>> _node_to_connected_sides;

  // Node to connected elements map
  std::map<Node *, std::set<Elem *>> _node_to_connected_elems;
};
