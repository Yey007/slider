#include "crc.hpp"
#include <Arduino.h>

// CRC-8-CCITT
// explaining why this is the binary representation is difficult in a comment
// off the bat it seems like there is no 1 for the x^8
// but this should help: https://youtu.be/sNkERQlK8j8?t=1103
const uint8_t CRC_GEN_POLYNOMIAL = 0b00000111; // x^8 + x^2 + x + 1

uint8_t calc_crc(uint8_t packetData[], size_t length)
{
  uint8_t crc = 0;

  for (size_t i = 0; i < length; i++)
  {
    uint8_t currentByte = packetData[i];

    for (uint8_t j = 0; j < 8; j++)
    {
      // copy paste from datasheet, honestly not sure wtf is going on here
      if ((crc >> 7) ^ (currentByte & 0x01))
      {
        crc = (crc << 1) ^ CRC_GEN_POLYNOMIAL;
      }
      else
      {
        crc = (crc << 1);
      }
      currentByte = currentByte >> 1;
    }
  }

  return crc;
}

bool verify_crc(uint8_t packetData[], size_t length, uint8_t crc)
{
  uint8_t packetCrc = calc_crc(packetData, length); // calculate crc without crc byte
  return crc == packetCrc;
}