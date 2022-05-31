//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "StingrayTestApp.h"
#include "StingrayApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
StingrayTestApp::validParams()
{
  InputParameters params = StingrayApp::validParams();
  return params;
}

StingrayTestApp::StingrayTestApp(InputParameters parameters) : MooseApp(parameters)
{
  StingrayTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

StingrayTestApp::~StingrayTestApp() {}

void
StingrayTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  StingrayApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"StingrayTestApp"});
    Registry::registerActionsTo(af, {"StingrayTestApp"});
  }
}

void
StingrayTestApp::registerApps()
{
  registerApp(StingrayApp);
  registerApp(StingrayTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
StingrayTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  StingrayTestApp::registerAll(f, af, s);
}
extern "C" void
StingrayTestApp__registerApps()
{
  StingrayTestApp::registerApps();
}
