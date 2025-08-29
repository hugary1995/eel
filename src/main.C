// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#include "EelTestApp.h"
#include "MooseMain.h"

int
main(int argc, char * argv[])
{
  return Moose::main<EelTestApp>(argc, argv);
}
