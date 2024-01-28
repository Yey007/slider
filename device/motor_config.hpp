#pragma once
#include <stdint.h>
#include "Arduino.h"
#include "math.h"

#define dist_t uint16_t
#define velo_t uint16_t
#define time_t uint16_t

const float NATIVE_STEP_ANGLE = 1.8;
const uint16_t MICROSTEPS = 1;
const float DRIVE_GEAR_RADIUS = 24.0;

const uint8_t NATIVE_STEPS_PER_REVOLUTION = 360 / NATIVE_STEP_ANGLE;
const float MM_PER_REVOLUTION = 2 * PI * DRIVE_GEAR_RADIUS; // TODO: Don't remember this
const float STEPS_PER_MM = (NATIVE_STEPS_PER_REVOLUTION * MICROSTEPS) / MM_PER_REVOLUTION;