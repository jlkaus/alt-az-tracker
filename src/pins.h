#ifndef _PINS_H
#define _PINS_H

// Define the pins used for our project.
// For the alt-az-tracker project, there is, at least:

// i2c bus pins for rtc and eeprom
// i2c address for rtc device
// i2c address for external eeprom (if we end up using it)
// rtc alarm interrupt input
// lcd control and data pins
// lcd backlight enable pin
// UI rotary encoder input pins, and selection input
// pins for the other 2 input buttons
// altitude quadrature input pins, including origin input
// azimuth quadrature input pins, including origin input
// reset pin?
// force bootloader pin?
// indicator LED pin
// serial port for console and control

#define UART_DDR DDRD
#define UART_PORT PORTD
#define UART_PIN PIND
#define UART_RX_BIT PIND0
#define UART_TX_BIT PIND1

#define LED_DDR DDRB
#define LED_PORT PORTB
#define LED_PIN PINB
#define LED_BIT PINB0

#define CFG_BAUD_RATE 38400
#define BAUD CFG_BAUD_RATE
#include <util/setbaud.h>

#endif
