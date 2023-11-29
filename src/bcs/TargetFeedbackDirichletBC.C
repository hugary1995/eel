// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#include "TargetFeedbackDirichletBC.h"

registerMooseObject("MooseApp", TargetFeedbackDirichletBC);

InputParameters
TargetFeedbackDirichletBC::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addClassDescription("Dirichlet boundary condition with simple linear feedback control");
  params.addRequiredParam<PostprocessorName>("monitor",
                                             "The postprocessor that monitors the output");
  params.addRequiredParam<Real>("target", "Target value for the monitor");
  params.addRequiredParam<Real>("window", "Acceptable window (target plus/minus window)");
  params.addRequiredParam<Real>("idle_value", "Value applied when idling");
  params.addRequiredParam<Real>("maintain_value", "Value applied to maintain the status");
  params.addRequiredParam<Real>("compensate_value", "Value applied to compensate the status");
  return params;
}

TargetFeedbackDirichletBC::TargetFeedbackDirichletBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _monitor(getPostprocessorValue("monitor")),
    _target(getParam<Real>("target")),
    _window(getParam<Real>("window")),
    _idle_value(getParam<Real>("idle_value")),
    _maintain_value(getParam<Real>("maintain_value")),
    _compensate_value(getParam<Real>("compensate_value")),
    _status(FeedBackStatus::IDLE)
{
}

void
TargetFeedbackDirichletBC::timestepSetup()
{

  _console << name() << ": feedback status: ";

  if (_status == FeedBackStatus::IDLE)
    if (_monitor < _target + _window)
    {
      _status = FeedBackStatus::MAINTAIN;
      _console << "MAINTAIN" << std::endl;
      return;
    }

  if (_status == FeedBackStatus::MAINTAIN)
  {
    if (_monitor < _target - _window)
    {
      _status = FeedBackStatus::COMPENSATE;
      _console << "COMPENSATE" << std::endl;
      return;
    }
    else if (_monitor > _target + 2 * _window)
    {
      _status = FeedBackStatus::IDLE;
      _console << "IDLE" << std::endl;
      return;
    }
  }

  if (_status == FeedBackStatus::COMPENSATE && _monitor > _target)
    if (_monitor > _target + _window)
    {
      _status = FeedBackStatus::MAINTAIN;
      _console << "MAINTAIN" << std::endl;
      return;
    }

  if (_status == FeedBackStatus::IDLE)
    _console << "IDLE" << std::endl;
  if (_status == FeedBackStatus::MAINTAIN)
    _console << "MAINTAIN" << std::endl;
  if (_status == FeedBackStatus::COMPENSATE)
    _console << "COMPENSATE" << std::endl;
}

Real
TargetFeedbackDirichletBC::computeQpResidual()
{
  Real value;

  if (_status == FeedBackStatus::IDLE)
    value = _idle_value;
  if (_status == FeedBackStatus::MAINTAIN)
    value = _maintain_value;
  if (_status == FeedBackStatus::COMPENSATE)
    value = _compensate_value;

  return _u[_qp] - value;
}
