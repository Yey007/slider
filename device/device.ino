#include "motor_config.hpp"
#include "bezier.hpp"
#include <stdint.h>
#include <math.h>
#include <TMCStepper.h>

#define STEP_PIN 2
#define DIR_PIN 3
#define EN_PIN 8
#define RX_PIN 7
#define TX_PIN 6

#define R_SENSE 0.15f // Not certain what this should be

TMC2208Stepper driver = TMC2208Stepper(RX_PIN, TX_PIN, R_SENSE);

void setup()
{
    Serial.begin(115200);

    pinMode(EN_PIN, OUTPUT);
    pinMode(STEP_PIN, OUTPUT);
    pinMode(DIR_PIN, OUTPUT);
    digitalWrite(EN_PIN, LOW); // Enable driver in hardware

    driver.beginSerial(115200); // Software UART drivers

    driver.begin(); // enables uart interface and sets driver to use register microsteps
    driver.toff(1); // Enables driver in software (can be any value except 0 for StealthChop)

    driver.internal_Rsense(true); // use internal sense resistors
    driver.rms_current(250, 0.2); // automatically calculates irun and ihold based on rms current and hold multiplier
    driver.iholddelay(10);        // some ramp down time to hold current (view docs for time calculation)
    driver.TPOWERDOWN(255);       // some time until ramp down begins (view docs for time calculation, this is around 5.6 seconds)
    driver.vsense(false);         // full voltage

    driver.en_spreadCycle(false); // use StealthChop

    driver.pwm_autoscale(true); // automatic motor voltage scaling based on tuning run. Can be switched to velocity based voltage scaling.
    driver.pwm_autograd(true);  // automatic motor voltage ramp up based on tuning run. Need to be switched off for velocity based scaling?

    driver.tbl(2); // not really sure what this does but recommended for most applications

    driver.microsteps(MICROSTEPS == 1 ? 0 : MICROSTEPS);
    driver.dedge(true); // double edge steps

    driver.push(); // push any settings to driver. shouldn't be required but I'm just being safe.

    uint16_t ms = driver.microsteps();
    Serial.print("Microsteps: ");
    Serial.println(ms);

    // autoTune();

    Bezier curve = Bezier(
        BezierEndpoint(0, 0),
        0,
        200,
        BezierEndpoint(200, 2000));

    run(curve, millis());
}

void loop()
{
}

void autoTune()
{
    uint8_t ihold_before = driver.ihold();
    uint8_t irun_before = driver.irun();

    // temporarily set ihold and irun to max for tuning
    driver.ihold(31);
    driver.irun(31);

    delay(100); // wait for auto tuning step 1 (standstill) to complete

    // TODO: probably replace with a bezier curve or velocity control once we know everything is working
    const uint32_t initial_speed = 100;
    const uint32_t max_speed = 500;
    const uint32_t max_velo_iterations = 4000;

    bool current_step = LOW;
    uint32_t current_speed = initial_speed;

    while (current_speed < max_speed)
    {
        digitalWrite(STEP_PIN, current_step);
        current_step = !current_step;
        microstepsPerSecondToDelay(current_speed);
        current_speed++; // This isn't really constant acceleration, but doesn't matter much at these speeds.
    }

    for (int i = 0; i < max_velo_iterations; i++)
    {
        digitalWrite(STEP_PIN, current_step);
        current_step = !current_step;
        microstepsPerSecondToDelay(current_speed);
    }

    while (current_speed > initial_speed)
    {
        digitalWrite(STEP_PIN, current_step);
        current_step = !current_step;
        microstepsPerSecondToDelay(current_speed);
        current_speed--;
    }

    driver.ihold(ihold_before);
    driver.irun(irun_before);
}

void microstepsPerSecondToDelay(uint32_t microsteps_per_second)
{
    // period: 1/f (seconds per microstep)
    double period_seconds = 1.0 / microsteps_per_second;
    uint32_t period_micros = period_seconds * 1000000;

    unsigned long start_micros = micros();
    while (micros() - start_micros < period_micros)
        continue;
}

dist_t current_ticks = 0;
bool current_step = LOW;
bool previous_reverse = false;

// TODO: we should really figure out what we wanna do in terms of torque control.
// Maybe we should load the profile onto the Arduino or the app or something,
// so we can check what motions are really possible and what motions are not. Though
// that might require knowing the load in more detail. We can deal with this later.
void run(Bezier curve, time_t startTime)
{
    while (true)
    {
        time_t now = millis() - startTime;

        if (now > curve.end.tMs)
        {
            return;
        }

        dist_t target_position = curve.sample(now);
        // Serial.println(target_position);

        if (abs(target_position - current_ticks) > 1)
        {
            // TODO: It seems like we can't generate step pulses fast enough to keep up with basic curves.
            // We need to optimize, reduce microsteps, or figure something else out.
            // Ideas for optimization: lookup table instead of on the fly curve computation (most likely to help, but there may be memory restrictions)
            // PWM for pulse generation? Frequency is a constant 980Hz tho so will that work?

            Serial.println("Can't keep up! More than a tick behind per iteration.");
        }

        bool reverse = target_position < current_ticks;
        digitalWrite(DIR_PIN, reverse);

        current_step = !current_step;
        digitalWrite(STEP_PIN, current_step);

        current_ticks += reverse ? -1 : 1;
    }
}
