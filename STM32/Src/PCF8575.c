#include "PCF8575.h"
#include "i2c.h"

bool PCF8575_SetOutputs(uint16_t value)
{
	if (I2C_SHARED_BUS.locked) {
		return false;
	}
	I2C_SHARED_BUS.locked = true;
	
	uint8_t data_high = (uint8_t)((value & 0xFF00) >> 8);
	uint8_t data_low = (uint8_t)value & 0x00FF;

	i2c_beginTransmission_u8(&I2C_SHARED_BUS, PCF8575_ADDR);
	i2c_write_u8(&I2C_SHARED_BUS, data_low);
	i2c_write_u8(&I2C_SHARED_BUS, data_high);
	
	i2c_write_u8(&I2C_SHARED_BUS, data_low);
	i2c_write_u8(&I2C_SHARED_BUS, data_high);

	uint8_t res = i2c_endTransmission(&I2C_SHARED_BUS);
	
	I2C_SHARED_BUS.locked = false;
	
	if (res != 0) {
		return false;
	}
	
	return true;
}
