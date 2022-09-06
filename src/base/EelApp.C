#include "EelApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
EelApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

EelApp::EelApp(InputParameters parameters) : MooseApp(parameters)
{
  EelApp::registerAll(_factory, _action_factory, _syntax);
}

EelApp::~EelApp() {}

void
EelApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"EelApp"});
  Registry::registerActionsTo(af, {"EelApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
EelApp::registerApps()
{
  registerApp(EelApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
EelApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  EelApp::registerAll(f, af, s);
}
extern "C" void
EelApp__registerApps()
{
  EelApp::registerApps();
}
