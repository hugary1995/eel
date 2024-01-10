// Copyright 2023, UChicago Argonne, LLC All Rights Reserved
// License: L-GPL 3.0
#pragma once

#include "MathUtils.h"
#include "PermutationTensor.h"

namespace MathUtils
{
template <typename T>
ADReal inner(const T & a, const T & b);
}

namespace MathUtils
{
template <>
inline ADReal
inner(const ADReal & a, const ADReal & b)
{
  return a * b;
}

template <>
inline ADReal
inner(const ADRealVectorValue & a, const ADRealVectorValue & b)
{
  return a * b;
}

template <>
inline ADReal
inner(const ADRankTwoTensor & a, const ADRankTwoTensor & b)
{
  return a.doubleContraction(b);
}

inline ADRankThreeTensor
leviCivita()
{
  ADRankThreeTensor e;
  for (auto i : make_range(3))
    for (auto j : make_range(3))
      for (auto k : make_range(3))
        e(i, j, k) = PermutationTensor::eps(i, j, k);
  return e;
}

}

namespace EelUtils
{
typedef Eigen::Matrix<ADReal, Eigen::Dynamic, 1> ADRealEigenVector;
typedef Eigen::Matrix<ADReal, Eigen::Dynamic, Eigen::Dynamic> ADRealEigenMatrix;

inline ADRealEigenVector
basisValues(const std::vector<std::vector<unsigned int>> & multi_index, const Point & q_point)
{
  unsigned int q = multi_index.size();
  ADRealEigenVector p(q);
  for (unsigned int r = 0; r < multi_index.size(); r++)
  {
    ADReal polynomial = 1.0;
    for (unsigned int c = 0; c < multi_index[r].size(); c++)
      for (unsigned int p = 0; p < multi_index[r][c]; p++)
        polynomial *= q_point(c);
    p(r) = polynomial;
  }
  return p;
}

inline ADRealEigenMatrix
basisGradients(const std::vector<std::vector<unsigned int>> & multi_index, const Point & q_point)
{
  unsigned int q = multi_index.size();
  ADRealEigenMatrix g = ADRealEigenMatrix::Zero(q, 3);
  for (unsigned int r = 0; r < multi_index.size(); r++)
    for (unsigned int i = 0; i < multi_index[r].size(); i++)
    {
      ADReal d = multi_index[r][i];
      for (unsigned int c = 0; c < multi_index[r].size(); c++)
        for (unsigned int p = 0; (c == i ? p + 1 : p) < multi_index[r][c]; p++)
          d *= q_point(c);
      g(r, i) = d;
    }
  return g;
}
}
