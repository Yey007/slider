#include "motor_config.hpp"
#include "bezier.hpp"

dist_t Bezier::sample(time_t time)
{
    float t = ((float)time) / (end.tMs - start.tMs);
    float oneMinus = 1 - t;

    float dist =
        start.xTicks * oneMinus * oneMinus * oneMinus +
        3 * control1 * oneMinus * oneMinus * t +
        3 * control2 * oneMinus * t * t +
        end.xTicks * t * t * t;

    return dist;
}

velo_t Bezier::sampleVelocity(time_t time)
{
    float t = ((float)time) / (end.tMs - start.tMs);
    float oneMinus = 1 - t;

    float velo =
        3 * oneMinus * oneMinus * (control1 - start.xTicks) +
        6 * oneMinus * t * (control2 - control1) +
        3 * t * t * (end.xTicks - control2);

    return velo;
}
