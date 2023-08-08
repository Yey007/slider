#pragma once
#include <Arduino.h>

uint8_t calc_crc(uint8_t packetData[], size_t length);
bool verify_crc(uint8_t packetData[], size_t length, uint8_t crc);