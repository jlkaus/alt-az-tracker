#ifndef _SERIAL_H
#define _SERIAL_H

// Helper functions to:
//    initialize the serial port
void serial_init();

//    try-receive a byte
uint8_t getch_async();

//    wait-receive bytes
uint8_t getch();

//    send a byte
void putch(uint8_t);

//    send bytes
int16_t write(const void *buf, uint16_t count);

#endif
