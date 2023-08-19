#pragma once
#include <stdint.h>
#include "Arduino.h"

// TODO: Some wrong math here. Shouldn't take 200 * 256 steps to do a full revolution. Conceptual misunderstanding?
const uint8_t NATIVE_STEPS_PER_REVOLUTION = 200; // TODO: Don't remember this
const uint16_t MICROSTEPS = 2;
const double MM_PER_REVOLUTION = 2 * PI * 24.0; // TODO: Don't remember this
const double MM_PER_STEP = MM_PER_REVOLUTION / (NATIVE_STEPS_PER_REVOLUTION * MICROSTEPS);