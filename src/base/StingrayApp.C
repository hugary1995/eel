#include "StingrayApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
StingrayApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

StingrayApp::StingrayApp(InputParameters parameters) : MooseApp(parameters)
{
  StingrayApp::registerAll(_factory, _action_factory, _syntax);
}

StingrayApp::~StingrayApp() {}

void
StingrayApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"StingrayApp"});
  Registry::registerActionsTo(af, {"StingrayApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
StingrayApp::registerApps()
{
  registerApp(StingrayApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
StingrayApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  StingrayApp::registerAll(f, af, s);
}
extern "C" void
StingrayApp__registerApps()
{
  StingrayApp::registerApps();
}
