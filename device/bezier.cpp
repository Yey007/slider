#include "motor_config.hpp"
#include "bezier.hpp"

dist_t Bezier::sample(time_t time)
{
    float t = ((float)time) / (end.tMs - start.tMs);
    float oneMinus = 1 - t;

    dist_t dist =
        start.xTicks * oneMinus * oneMinus * oneMinus +
        3 * control1 * oneMinus * oneMinus * t +
        3 * control2 * oneMinus * t * t +
        end.xTicks * t * t * t;

    return dist;
}
