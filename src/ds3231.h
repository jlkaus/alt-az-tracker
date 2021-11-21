#ifndef _DS3231_H
#define _DS3231_H

// Helper functions to:
//   read the current time and data information
//   set the time and date information
//   set alarm time and date
//   enable/disable the alarms
//   read the current temperature

// do whatever is necessary to initialize i2c and the rtc chip
void rtc_init();


typedef struct {
  uint8_t res1:1;
  uint8_t s10:3;
  uint8_t s1:4;

  uint8_t res2:1;
  uint8_t m10:3;
  uint8_t m1:4;

  uint8_t res3:1;
  uint8_t h24:1;
  uint8_t h10:2;
  uint8_t h1:4;

  uint8_t res4:5;
  uint8_t doy1:3;

  uint8_t res5:2;
  uint8_t d10:2;
  uint8_t d1:4;

  uint8_t y100:1;
  uint8_t res6:2;
  uint8_t m10:1;
  uint8_t m1:4;

  uint8_t y10:4;
  uint8_t y1:4;
} timestamp_t;

// function to read the time and date
void rtc_read_ts(timestamp_t *ts);

// extract time and data parameters from buffer that was read in
uint16_t rtc_extract_year(const timestamp_t *ts);



// function to read the temperature
uint16_t rtc_read_temp();


// function to set the time and date
void rtc_write_ts(timestamp_t *ts);


// function to set one of the alarms time/date



// function to enable/disable one of the alarms




#endif
