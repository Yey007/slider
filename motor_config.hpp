const uint8_t NATIVE_STEPS_PER_REVOLUTION = 200; // TODO: Don't remember this
const uint16_t MICROSTEPS = 256;
const double MM_PER_REVOLUTION = 24.0; // TODO: Don't remember this
const double MM_PER_STEP = MM_PER_REVOLUTION / (NATIVE_STEPS_PER_REVOLUTION * MICROSTEPS);