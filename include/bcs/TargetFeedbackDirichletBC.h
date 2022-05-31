// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "NodalBC.h"

class TargetFeedbackDirichletBC : public NodalBC
{
public:
  static InputParameters validParams();

  TargetFeedbackDirichletBC(const InputParameters & parameters);

  void timestepSetup() override;

protected:
  virtual Real computeQpResidual() override;

  const PostprocessorValue & _monitor;

  const Real _target;
  const Real _window;
  const Real _idle_value;
  const Real _maintain_value;
  const Real _compensate_value;

  enum class FeedBackStatus
  {
    IDLE,
    MAINTAIN,
    COMPENSATE
  } _status;
};
