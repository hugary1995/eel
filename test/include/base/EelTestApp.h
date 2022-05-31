// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "MooseApp.h"

class EelTestApp : public MooseApp
{
public:
  static InputParameters validParams();

  EelTestApp(InputParameters parameters);
  virtual ~EelTestApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs = false);
};
