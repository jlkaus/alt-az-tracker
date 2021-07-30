#ifndef _HELPER_H
#define _HELPER_H

// Some helper functions for common simple behaviors
// soft reset
void soft_reset();

// enter bootloader
void enter_bootloader();

// flash an led
void flash_led(uint8_t count);

// do an SRC hang
void src_hang(uint8_t count);

// disable the watchdog timer
void wdt_init() __attribute__((naked)) __attribute__((section(".init3")));

// initialize the led pin
void led_init();


#endif
