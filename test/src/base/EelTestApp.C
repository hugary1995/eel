//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "EelTestApp.h"
#include "EelApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
EelTestApp::validParams()
{
  InputParameters params = EelApp::validParams();
  return params;
}

EelTestApp::EelTestApp(InputParameters parameters) : MooseApp(parameters)
{
  EelTestApp::registerAll(_factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

EelTestApp::~EelTestApp() {}

void
EelTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  EelApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"EelTestApp"});
    Registry::registerActionsTo(af, {"EelTestApp"});
  }
}

void
EelTestApp::registerApps()
{
  registerApp(EelApp);
  registerApp(EelTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
EelTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  EelTestApp::registerAll(f, af, s);
}
extern "C" void
EelTestApp__registerApps()
{
  EelTestApp::registerApps();
}
