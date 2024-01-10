// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0

#pragma once

#include "VectorKernel.h"

/**
 *  Weak form contribution corresponding to the curl(p curl(A))
 */
class VectorCurlCurl : public VectorKernel
{
public:
  static InputParameters validParams();

  VectorCurlCurl(const InputParameters & params);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  /// curl of the test function
  const VectorVariableTestCurl & _curl_test;

  /// curl of the shape function
  const VectorVariablePhiCurl & _curl_phi;

  /// Holds the solution curl at the current quadrature points
  const VectorVariableCurl & _curl_u;

  /// Property to be multiplied
  const MaterialProperty<Real> & _prop;

  /// Scalar coefficient
  Real _coeff;
};
