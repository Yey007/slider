#pragma once
#include <stdint.h>

namespace bezier
{
    typedef uint16_t dist_t;
    typedef uint16_t time_t;

    struct BezierEndpoint
    {
    public:
        BezierEndpoint(dist_t x, time_t time) : xTicks(x), tMs(time) {}

        dist_t xTicks;
        time_t tMs;
    };

    struct BezierCurve
    {
    public:
        BezierEndpoint start, end;
        dist_t control1, control2;

        BezierCurve(BezierEndpoint start, dist_t control1, dist_t control2, BezierEndpoint end) : start(start), end(end), control1(control1), control2(control2) {}

        dist_t sample(time_t time);
    };
}
