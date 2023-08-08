#include "stepper.hpp"
#include <TMC2208Stepper.h>

#define STEP_PIN 2
#define DIR_PIN 3
#define EN_PIN 8
#define RX_PIN 7
#define TX_PIN 6

TMC2208Stepper driver = TMC2208Stepper(RX_PIN, TX_PIN);

void setup()
{
  Serial.begin(115200);
  driver.beginSerial(115200);
  // Push at the start of setting up the driver resets the register to default
  driver.push();

  pinMode(EN_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
  digitalWrite(EN_PIN, HIGH); // Disable driver in hardware

  driver.pdn_disable(true);     // Use PDN/UART pin for communication
  driver.I_scale_analog(false); // Use internal voltage reference
  driver.rms_current(500);      // Set driver current 500mA
  driver.toff(2);               // Enable driver in software

  digitalWrite(EN_PIN, LOW); // Enable driver in hardware

  driver.microsteps(256);
  driver.push();

  uint8_t conn = driver.test_connection();
  Serial.print("Connection: ");
  Serial.println(conn);

  uint16_t ms = driver.microsteps();
  Serial.print("Microsteps: ");
  Serial.println(ms);

  uint32_t data = 0;
  Serial.print("DRV_STATUS = 0x");
  driver.DRV_STATUS(&data);
  Serial.println(data, HEX);
}

void loop()
{
  digitalWrite(STEP_PIN, !digitalRead(STEP_PIN));
  delayMicroseconds(100);
}

// void setup()
// {
//   Serial.begin(9600);
//   Serial.println("Hello World!");

//   Stepper stepper(STEP_PIN, DIR_PIN, TX_PIN, RX_PIN);
//   bool success = stepper.setMicrosteps(MicrostepMode::TWO_FIFTY_SIXTH_STEP);

//   digitalWrite(EN_PIN, LOW);

//   Serial.println(success);
// }

// void loop()
// {
// }
