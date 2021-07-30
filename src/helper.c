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
#include "helper.h"

void led_init() {
  // setup the LED pin for output
  LED_DDR |= _BV(LED_BIT);
  LED_PORT &= ~_BV(LED_BIT);
}

void flash_led(uint8_t count) {
  for(uint8_t i = 0; i < count; ++i) {
    LED_PORT |= _BV(LED_BIT);
    _delay_ms(100);
    LED_PORT &= ~_BV(LED_BIT);
    _delay_ms(100);
  }
}

void src_hang(uint8_t count) {
  // hang forever, periodically flashing our SRC code via the indicator led.
  for(;;) {
    flash_led(count);
    _delay_ms(1000);
  }
}

void wdt_init() {
  // disable the wdt so we don't get continuously reset under normal conditions
  MCUSR = 0;
  wdt_disable();
}

void soft_reset() {
  // Re-enable the wdt and hang.  It will reset us eventually.
  wdt_enable(WDTO_15MS);
  for(;;) {
    // do nothing
  }
}
