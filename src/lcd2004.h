#ifndef _LCD2004_H
#define _LCD2004_H

// Helper functions to:
//   initialize the LCD
void lcd_init();

//   clear the screen
void lcd_clear();

//   turn the screen on and off
void lcd_disable();
void lcd_enable();

//   position the cursor
void lcd_move_to(uint8_t row, uint8_t col);

//   write one or more characters to the screen memory
void lcd_putch(char);

//   perhaps simple printf-like functions to blit floats or formatted strings?
int16_t lcd_write(const char *buf, uint16_t count);


#endif
