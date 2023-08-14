#pragma once
#include "time.hpp"
#include "distance.hpp"

struct BezierPoint
{
public:
  Distance x;
  Time time;
};

struct Bezier
{
public:
  BezierPoint start, control1, control2, end;

  Distance sample(Time time);
};
