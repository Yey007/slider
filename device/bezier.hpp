#pragma once
#include "src/measures/time.hpp"
#include "src/measures/distance.hpp"
#include "src/measures/velocity.hpp"

struct BezierEndpoint
{
public:
    BezierEndpoint(Distance x, Time time) : x(x), time(time) {}

    Distance x;
    Time time;
};

struct Bezier
{
public:
    BezierEndpoint start, end;
    Distance control1, control2;

    Bezier(BezierEndpoint start, Distance control1, Distance control2, BezierEndpoint end) : start(start), control1(control1), control2(control2), end(end) {}

    Distance sample(Time time);
};
