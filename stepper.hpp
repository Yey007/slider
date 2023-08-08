#pragma once
#include <Arduino.h>
#include "crc.hpp"

enum MicrostepMode : uint8_t
{
  FULL_STEP = 0b1000,
  HALF_STEP = 0b0111,
  QUARTER_STEP = 0b0110,
  EIGHTH_STEP = 0b0101,
  SIXTEENTH_STEP = 0b0100,
  THIRTY_SECOND_STEP = 0b0011,
  SIXTY_FOURTH_STEP = 0b0010,
  ONE_TWENTY_EIGHTH_STEP = 0b0001,
  TWO_FIFTY_SIXTH_STEP = 0b0000
};

enum Direction : uint8_t
{
  CLOCKWISE = 0,
  COUNTER_CLOCKWISE = 1
};

enum Register : uint8_t
{
  CHOPCONF = 0x6c,
};

class Stepper
{
public:
  Stepper(uint8_t stepPin, uint8_t dirPin, uint8_t uartTxPin, uint8_t uartRxPin);

  void step();

  void setDirection(Direction direction);

  bool setMicrosteps(MicrostepMode mode);

private:
  uint8_t m_stepPin;
  uint8_t m_dirPin;
  uint8_t m_uartTxPin;
  uint8_t m_uartRxPin;

  void write_register(Register address, uint32_t value);

  uint32_t read_register(Register address, bool *success);

  void read_register_request(Register address);

  uint32_t read_register_response(bool *success);

  void send(uint8_t packet[], size_t length);

  void send_bit(uint8_t bit);

  bool receive(uint8_t packet[], size_t length);

  uint8_t receive_bit();
};
