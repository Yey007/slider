#pragma once
#include "motor_config.hpp"

struct BezierEndpoint
{
public:
    BezierEndpoint(dist_t x, time_t time) : xTicks(x), tMs(time) {}

    dist_t xTicks;
    time_t tMs;
};

struct Bezier
{
public:
    BezierEndpoint start, end;
    dist_t control1, control2;

    Bezier(BezierEndpoint start, dist_t control1, dist_t control2, BezierEndpoint end) : start(start), control1(control1), control2(control2), end(end) {}

    dist_t sample(time_t time);
    velo_t sampleVelocity(time_t time);
};
