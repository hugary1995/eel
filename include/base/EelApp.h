// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "MooseApp.h"

class EelApp : public MooseApp
{
public:
  static InputParameters validParams();

  EelApp(InputParameters parameters);
  virtual ~EelApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s);
};
