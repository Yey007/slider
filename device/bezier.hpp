#pragma once
#include "time.hpp"
#include "distance.hpp"

struct BezierPoint
{
public:
  BezierPoint(Distance x, Time time) : x(x), time(time) {}

  Distance x;
  Time time;
};

struct Bezier
{
public:
  Bezier(BezierPoint start, BezierPoint control1, BezierPoint control2, BezierPoint end) : start(start), control1(control1), control2(control2), end(end) {}

  BezierPoint start, control1, control2, end;

  Distance sample(Time time);
};
