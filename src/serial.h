#ifndef _SERIAL_H
#define _SERIAL_H

// Helper functions to:
//    initialize the serial port
void serial_init();

//    try-receive a byte
char serial_getch_async();

//    wait-receive bytes
char serial_getch();

//    send a byte
void serial_putch(char);

//    send bytes
int16_t serial_write(const char *buf, uint16_t count);

#endif
