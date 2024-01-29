#ifndef __PCF8575_H
#define __PCF8575_H

#include "hardware.h"

#define PCF8575_ADDR 0x20 // A0=GND，A1=GND,A2=GND

extern bool PCF8575_SetOutputs(uint16_t value);

#endif
