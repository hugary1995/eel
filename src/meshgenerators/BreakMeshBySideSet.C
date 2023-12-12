// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "BreakMeshBySideSet.h"
#include "CastUniquePointer.h"
#include "MooseMeshUtils.h"

#include "libmesh/partitioner.h"

registerMooseObject("MooseApp", BreakMeshBySideSet);

InputParameters
BreakMeshBySideSet::validParams()
{
  InputParameters params = MeshGenerator::validParams();
  params.addClassDescription(
      "Break all element-element interfaces on the specified boundaries. The boundaries should be "
      "'internal' to the mesh so that element pairs can be located.");
  params.addRequiredParam<MeshGeneratorName>("input", "The mesh we want to modify");
  params.addParam<std::vector<BoundaryName>>("boundaries",
                                             "The list of boundary IDs/Names to break.");
  return params;
}

BreakMeshBySideSet::BreakMeshBySideSet(const InputParameters & parameters)
  : MeshGenerator(parameters),
    _input(getMesh("input")),
    _boundary_names(getParam<std::vector<BoundaryName>>("boundaries"))
{
}

std::unique_ptr<MeshBase>
BreakMeshBySideSet::generate()
{

  std::unique_ptr<MeshBase> mesh = std::move(_input);
  BoundaryInfo & boundary_info = mesh->get_boundary_info();

  // Works for 2D only
  if (mesh->dim() != 2)
    mooseError("This mesh generator only works for 2D mesh.");

  // Check that the boundaries exist in the mesh
  // Get the boundary IDs if they exist
  for (const auto & name : _boundary_names)
  {
    if (!MooseMeshUtils::hasBoundaryName(*mesh, name))
      paramError("boundaries", "The boundary '", name, "' was not found in the mesh");
    _boundaries.push_back(MooseMeshUtils::getBoundaryID(name, *mesh));
  }

  buildNodeToSideMap(*mesh);
  buildNodeToElemMap(*mesh);

  duplicateNodes(*mesh);

  Partitioner::set_node_processor_ids(*mesh);

  return dynamic_pointer_cast<MeshBase>(mesh);
}

void
BreakMeshBySideSet::buildNodeToSideMap(MeshBase & mesh) const
{
  BoundaryInfo & boundary_info = mesh.get_boundary_info();
  auto sidesets = boundary_info.build_active_side_list();

  for (auto && [e, s, b] : sidesets)
  {
    // Skip if this is not the boundary specified
    if (std::find(_boundaries.begin(), _boundaries.end(), b) == _boundaries.end())
      continue;

    auto elem = mesh.elem_ptr(e);
    for (auto n : elem->nodes_on_side(s))
      _node_to_connected_sides[elem->node_ptr(n)].emplace_back(elem, s);
  }
}

void
BreakMeshBySideSet::buildNodeToElemMap(MeshBase & mesh) const
{
  for (auto && [node, sides] : _node_to_connected_sides)
    if (sides.size() > 1)
    {
      auto && [elem, s] = sides[0];
      elem->find_point_neighbors(*node, _node_to_connected_elems[node]);
    }
}

void
BreakMeshBySideSet::duplicateNodes(MeshBase & mesh) const
{
  for (auto && [node, connected_elems] : _node_to_connected_elems)
}

void
BreakMeshBySideSet::duplicateNode(MeshBase & mesh, Elem * elem, const Node * node) const
{
  std::unique_ptr<Node> new_node = Node::build(*node, Node::invalid_id);
  new_node->processor_id() = elem->processor_id();
  Node * added_node = mesh.add_node(std::move(new_node));
  for (const auto j : elem->node_index_range())
    if (elem->node_id(j) == node->id())
    {
      elem->set_node(j) = added_node;
      break;
    }
}
