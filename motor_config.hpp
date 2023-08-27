#pragma once
#include <stdint.h>
#include "Arduino.h"

const uint8_t NATIVE_STEPS_PER_REVOLUTION = 200; // TODO: Don't remember this
const uint16_t MICROSTEPS = 256;
const double MM_PER_REVOLUTION = 2 * PI * 24.0; // TODO: Don't remember this
const double STEPS_PER_MM = (NATIVE_STEPS_PER_REVOLUTION * MICROSTEPS) / MM_PER_REVOLUTION;