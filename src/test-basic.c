// Basic test firmware that:
// spits out boot-time messages on the serial port
// blinks the LED a few times
// accepts characters on the serial port, blinks the LED once for each one, and sends a message back containing the character, case swapped
// if sent a 'q' character, does an SRC hang indicating this.
// if sent an 'r' character, does a soft-reset of the firmware.
#include <stdint.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <avr/boot.h>
#include <util/delay.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>

#include "pins.h"
#include "serial.h"
#include "helper.h"

const char fw_datestring[] = __TIMESTAMP__;
const char fw_bootstring[] = "TEST-BASIC FW BOOTUP 0001";


int main() {
  asm volatile("nop\n\t");

  led_init();
  flash_led(1);

  serial_init();
  flash_led(2);

  write(fw_bootstring, sizeof(fw_bootstring));
  write(fw_datestring, sizeof(fw_datestring));

  flash_led(3);
  for(;;) {
    uint8_t c = getch_async();
    if(c != 0x00) {
      flash_led(1);
      // case convert character and repeat it back out
      c ^= 0x20;
      putch(c);

      if(c == 'Q') {
        src_hang(9);
      } else if(c == 'R') {
        break;
      }
    }
  }

  flash_led(7);
  soft_reset();
}
