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

#define LCD_DDR DDRB
#define LCD_PORT PORTB
#define LCD_PIN PINB
#define LCD_RS_BIT PINB2
#define LCD_EN_BIT PINB3
#define LCD_DATA_MASK 0xF0
#define LCD_DATA_SHIFT 4

#define UI_DDR DDRD
#define UI_PORT PORTD
#define UI_PIN PIND
#define UI_PCIG PCIE3
#define UI_PCMSK PCMSK3
#define UI_B1_BIT PIND2
#define UI_B0_BIT PIND3
#define UI_ENC_BIT PIND4
#define UI_ENB_BIT PIND5
#define UI_ENA_BIT PIND6
#define UI_SWQ_BIT PIND7

#define QUAD_DDR DDRA
#define QUAD_PORT PORTA
#define QUAD_PIN PINA
#define QUAD_PCIG PCIE0
#define QUAD_PCMSK PCMSK0
#define QUAD_ALTA_BIT PINA0
#define QUAD_ALTB_BIT PINA1
#define QUAD_ALTZ_BIT PINA2
#define QUAD_AZA_BIT PINA3
#define QUAD_AZB_BIT PINA4
#define QUAD_AZZ_BIT PINA5

#define CFG_BAUD_RATE 38400
#define BAUD CFG_BAUD_RATE
#include <util/setbaud.h>

#define CFG_TWI_SCK 100000
// This works if the prescalar is 1.  If it needs to be higher, you'd divide this number by 4 for each increase in prescalar
// for F_CPU of 20MHz, prescalar can be 1 all the way down to about a TWI clock speed of 40kHz or so, then you'd need to up
// the prescalar...
#define TWBR_VALUE  (((( (F_CPU) / (CFG_TWI_SCK) ) - 16 ) / 2 ))

#endif
