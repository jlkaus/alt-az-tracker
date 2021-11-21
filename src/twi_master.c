#include <stdint.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <avr/boot.h>
#include <util/delay.h>
#include <util/twi.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>

#include "pins.h"
#include "twi_master.h"

static uint8_t twi_reset_bus() {
  // clear TWSTA
  // set TWINT, TWSTO
  // wait for TWSTO to clear? TWINT doesn't trigger.
  // return TW_STATUS
}

static uint8_t twi_send_start() {
  // clear TWSTO
  // set TWINT, TWSTA, TWEN
  // wait for TWINT
  // return TW_STATUS
}
static uint8_t twi_send_byte(uint8_t data) {
  // set TWDR=data
  // clear TWSTO, TWSTA
  // set TWINT, TWEN
  // wait for TWINT
  // return TW_STATUS
}
static uin8_t twi_send_stop() {
  // clear TWSTA
  // set TWINT, TWEN, TWSTO
  // wait for TWSTO to clear?  TWINT doesn't trigger.
  // return TW_STATUS
}
static uint8_t twi_recv_byte(uint8_t *data, bool ack) {
  // clear TWSTO, TWSTA, (TWEA if !ack)
  // set TWINT, TWEN, (TWEA if ack)
  // wait for TWINT
  // set *data=TWDR
  // return TW_STATUS
}

void twi_write_addr(uint8_t dev_addr, uint8_t reg_addr, const uint8_t *data, uint16_t length) {
  // Write, with register address byte sent.
  twi_send_start() == TW_START;
  twi_send_byte(dev_addr << 1 | TW_WRITE) == TW_MT_SLA_ACK;
  // if TW_MT_SLA_NACK, abort with failure (no such device).  reset the bus.
  twi_send_byte(reg_addr) == TW_MT_DATA_ACK;
  // if TW_MT_DATA_NACK, abort with failure (device not accepting data).  reset the bus.
  for(size_t i = 0; i < length; ++i) {
    twi_send_byte(data[i]) == TW_MT_DATA_ACK;
    // if TW_MT_DATA_NACK, abort with failure (device not accepting data).  reset the bus.
  }
  twi_send_stop();
}


void twi_read_addr(uint8_t dev_addr, uint8_t reg_addr, uint8_t *data, uint16_t length) {
  // Read, but first send register address byte.
  twi_send_start() == TW_START;
  twi_send_byte(dev_addr << 1 | TW_WRITE) == TW_MT_SLA_ACK;
  // if TW_MT_SLA_NACK, abort with failure (no such device). reset the bus.
  twi_send_byte(reg_addr) == TW_MT_DATA_ACK;
  // if TW_MT_DATA_NACK, abort with failure (device not accepting data).  reset the bus.
  twi_send_start() == TW_REP_START;
  twi_send_byte(dev_addr << 1 | TW_READ) == TW_MR_SLA_ACK;
  // if TW_MR_SLA_NACK, abort with failure (no such device). reset the bus.
  for(size_t i = 0; i < length - 1; ++i) {
    twi_recv_byte(data + i, true) == TW_MR_DATA_ACK;
  }
  twi_recv_byte(data + length - 1, false) == TW_MR_DATA_NACK;
  twi_send_stop();
}

void twi_read_cur(uint8_t dev_addr, uint8_t *data, uint16_t length) {
  // Simple read without sending the register address first, no repeated start.
  twi_send_start() == TW_START;
  twi_send_byte(dev_addr << 1 | 1) == TW_MR_SLA_ACK;
  // if TW_MR_SLA_NACK, abort with failure (no such device)
  for(size_t i = 0; i < length - 1; ++i) {
    twi_recv_byte(data + i, true) == TW_MR_DATA_ACK;
  }
  twi_recv_byte(data + length - 1, false) == TW_MR_DATA_NACK;
  twi_send_stop();
}

void twi_init_master() {
  // enable pullups on SDA/SCL
  // disable top level TWI interrupts: clear TWIE in TWCR
  // set TWI bitrate (TWBR/TWSR(TWPS))
  // set the slave address to 0, with no general call handling, and disable slave response: clear TWAR and TWAMR, clear TWGCE in TWAR, clear TWEA in TWCR
  // power on the TWI interface (PRTWI in PRR)
}
