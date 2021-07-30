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

void serial_init() {
  UBRR0L = UBRRL_VALUE;
  UBRR0H = UBRRH_VALUE;
  UCSR0B = (1<<RXEN0) | (1<<TXEN0);
  UCSR0C = (1<<UCSZ00) | (1<<UCSZ01);

  // enable internal pull-up for UART RX to suppress line noise
  UART_DDR &= ~_BV(UART_RX_BIT);
  UART_PORT |= _BV(UART_RX_BIT);

}

uint8_t getch() {
  while(!(UCSR0A & _BV(RXC0)));
  return UDR0;
}

uint8_t getch_async() {
  if(UCSR0A & _BV(RXC0)) {
    return UDR0;
  } else {
    return 0x00;
  }
}

void putch(uint8_t ch) {
  while(!(UCSR0A & _BV(UDRE0)));
  UDR0 = ch;
}

int16_t write(const void *buf, uint16_t count) {
  uint16_t i = 0;
  for(; i < count; ++i) {
    putch(((uint8_t *)buf)[i]);
  }
  return (int16_t)i;
}
