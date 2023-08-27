#pragma once
#include <stdint.h>
#include "Arduino.h"

const uint8_t NATIVE_STEPS_PER_REVOLUTION = 200; // TODO: Don't remember this
const uint16_t MICROSTEPS = 8;
const float MM_PER_REVOLUTION = 2 * PI * 24.0; // TODO: Don't remember this
const float STEPS_PER_MM = (NATIVE_STEPS_PER_REVOLUTION * MICROSTEPS) / MM_PER_REVOLUTION;