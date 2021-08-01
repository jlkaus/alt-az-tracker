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
#include "lcd2004.h"
#include "ds3231.h"

const char fw_datestring[] = __TIMESTAMP__;
const char fw_bootstring[] = "TEST-RTC FW BOOTUP 0001";


int main() {
  asm volatile("nop\n\t");

  led_init();
  flash_led(1);

  serial_init();
  flash_led(2);

  lcd_init();
  flash_led(3);

  rtc_init();
  flash_led(4);

  serial_write(fw_bootstring, sizeof(fw_bootstring));
  serial_write(fw_datestring, sizeof(fw_datestring));








  flash_led(4);
  for(;;) {
    uint8_t c = serial_getch_async();
    if(c != 0x00) {
      flash_led(1);
      // case convert character and repeat it back out
      lcd_putch(c);
      c ^= 0x20;
      serial_putch(c);

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
