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
#include "lcd2004.h"

static void lcd_send_nibble(uint8_t data) {
  // set data pins
  LCD_PORT = (LCD_PORT & ~LCD_DATA_MASK) | ((data & 0xF) << LCD_DATA_SHIFT);

  LCD_PORT &= ~_BV(LCD_EN_BIT);
  _delay_us(1);
  LCD_PORT |= _BV(LCD_EN_BIT);
  _delay_us(1);
  LCD_PORT &= ~_BV(LCD_EN_BIT);
  _delay_us(1);
}

static void lcd_send_data(uint8_t rs, uint8_t data) {
  if(rs) {
    LCD_PORT |= _BV(LCD_RS_BIT);
  } else {
    LCD_PORT &= ~_BV(LCD_RS_BIT);
  }

  _delay_us(1);
  lcd_send_nibble(data >> 4);
  lcd_send_nibble(data & 0xF);
  _delay_us(1);

  _delay_us(40);
}

void lcd_init() {
  // Set the LCD control pins as output pins, clearing them by default
  LCD_DDR |= _BV(LCD_RS_BIT) | _BV(LCD_EN_BIT) | LCD_DATA_MASK;
  LCD_PORT &= ~_BV(LCD_RS_BIT) & ~_BV(LCD_EN_BIT) & ~LCD_DATA_MASK;

  // RS bit is already cleared.
  //LCD_PORT &= ~_BV(LCD_RS_BIT);
  // _delay_us(1);

  _delay_ms(15);

  lcd_send_nibble(0x03);
  _delay_ms(4.1);

  lcd_send_nibble(0x03);
  _delay_us(100);

  lcd_send_nibble(0x03);
  _delay_us(40);

  lcd_send_nibble(0x02);  // finally we can be certain we are in 8-bit mode, but move to 4-bit mode.  Unfortunately, can't control N/F bits here.
  _delay_us(40);

  lcd_send_data(0, 0x28); // Set 4-bit mode again, this time setting N (2-lines), clearing F (5x8 bitmap mode)
  lcd_send_data(0, 0x08); // Display Set, turning off the display, the cursor, and blink
  lcd_send_data(0, 0x01); // Clear the display
  _delay_ms(2);

  lcd_send_data(0, 0x06); // Entry mode Set, I/D=1 (increment), S=0 (no shift)
}

void lcd_clear() {
  lcd_send_data(0, 0x01);
  _delay_ms(2);
}

void lcd_disable() {
  lcd_send_data(0, 0x08);
}

void lcd_enable() {
  lcd_send_data(0, 0x0C);
}

void lcd_move_to(uint8_t row, uint8_t col) {
  uint8_t a = 0;
  if(row == 0) {
    a = 0x00;
  } else if(row == 1) {
    a = 0x40;
  } else if(row == 2) {
    a = 0x14;
  } else if(row == 3) {
    a = 0x54;
  }
  a += col;
  lcd_send_data(0, 0x80 + a);
}

void lcd_putch(char c) {
  lcd_send_data(1, (uint8_t)c);
}

int16_t lcd_write(const char *buf, uint16_t count) {
  uint16_t i = 0;
  for(; i < count; ++i) {
    lcd_putch(buf[i]);
  }
  return (int16_t)i;
}
