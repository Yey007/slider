
#include <Arduino.h>
#include <TMCStepper.h>

#include "motor_config.hpp"
#include <bezier.hpp>

#define STEP_PIN D2
#define DIR_PIN D3
#define EN_PIN D4

#define SERIAL_PORT Serial1
#define RX_PIN D5
#define TX_PIN D6

#define R_SENSE 0.11f // Board sense resistors are 110mOhm afaik

TMC2208Stepper driver = TMC2208Stepper(&SERIAL_PORT, R_SENSE);

// TODO: we should really figure out what we wanna do in terms of torque control.
// Maybe we should load the profile onto the Arduino or the app or something,
// so we can check what motions are really possible and what motions are not. Though
// that might require knowing the load in more detail. We can deal with this later.
void runBezier(bezier::BezierCurve curve, bezier::time_t startTime)
{
    bezier::dist_t currentTicks = 0;
    bool currentStep = LOW;

    while (true)
    {
        bezier::time_t now = millis() - startTime;

        if (now > curve.end.tMs)
        {
            break;
        }

        bezier::dist_t target_position = curve.sample(now);
        int32_t diff = (int32_t)target_position - (int32_t)currentTicks;

        if (abs(diff) > 1)
        {
            Serial.print("Can't keep up! ");
            Serial.print(abs(diff));
            Serial.println(" ticks behind.");
        }

        bool reverse = diff < 0;
        digitalWrite(DIR_PIN, reverse);

        currentStep = !currentStep;
        digitalWrite(STEP_PIN, currentStep);

        currentTicks += reverse ? -1 : 1;
    }
}

void runController()
{
    pinMode(EN_PIN, OUTPUT);
    pinMode(STEP_PIN, OUTPUT);
    pinMode(DIR_PIN, OUTPUT);

    digitalWrite(STEP_PIN, LOW);
    digitalWrite(DIR_PIN, LOW);
    digitalWrite(EN_PIN, LOW); // Enable driver in hardware

    SERIAL_PORT.begin(115200, SERIAL_8N1, RX_PIN, TX_PIN);

    driver.begin(); // enables uart interface and sets driver to use register microsteps
    driver.toff(1); // Enables driver in software (can be any value except 0 for StealthChop)

    driver.internal_Rsense(false); // don't use internal sense resistors (board should have some)
    driver.rms_current(200, 0.2);  // automatically calculates irun and ihold based on rms current and hold multiplier
    driver.iholddelay(10);         // some ramp down time to hold current (view docs for time calculation)
    driver.TPOWERDOWN(255);        // some time until ramp down begins (view docs for time calculation, this is around 5.6 seconds)

    driver.en_spreadCycle(false); // use StealthChop

    driver.pwm_autoscale(false); // velocity based voltage scaling
    driver.pwm_autograd(false);  // off for above

    driver.tbl(2); // not really sure what this does but recommended for most applications

    driver.microsteps(MICROSTEPS == 1 ? 0 : MICROSTEPS);
    driver.dedge(true); // double edge steps

    driver.push(); // push any settings to driver. shouldn't be required but I'm just being safe.

    uint16_t ms = driver.microsteps();
    Serial.print("Microsteps: ");
    Serial.println(ms);

    bezier::BezierCurve curve = bezier::BezierCurve(
        bezier::BezierEndpoint(0, 0),
        16,
        35,
        bezier::BezierEndpoint(50, 500));

    runBezier(curve, millis());

    Serial.println("Run finished.");
}