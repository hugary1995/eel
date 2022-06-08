#include "MathUtils.h"

namespace MathUtils
{
template <typename T>
ADReal inner(const T & a, const T & b);
}

namespace MathUtils
{
template <>
ADReal
inner(const ADReal & a, const ADReal & b)
{
  return a * b;
}

template <>
ADReal
inner(const ADRealVectorValue & a, const ADRealVectorValue & b)
{
  return a * b;
}

template <>
ADReal
inner(const ADRankTwoTensor & a, const ADRankTwoTensor & b)
{
  return a.doubleContraction(b);
}
}
