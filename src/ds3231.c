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
#include "ds3231.h"
#include "twi_master.h"

void rtc_init() {
  // set SWQ to input pin
  // enable pullup on SWQ

  twi_init_master();
}

void rtc_read_ts(timestamp_t *ts) {


}

void rtc_write_ts(const timestamp_t *ts) {


}

uint16_t rtc_read_temp() {

}

uint16_t ts_year(const timestamp_t *ts) {

}

void ts_set_year(timestamp_t *ts, uint16_t year) {

}

uint8_t ts_month(const timestamp_t *ts) {

}
void ts_set_month(timestamp_t *ts, uint8_t month) {

}

uint8_t ts_day(const timestamp_t *ts) {

}
void ts_set_day(timestamp_t *ts, uint8_t day) {

}
uint8_t ts_hour(const timestamp_t *ts) {

}
void ts_set_hour(timestamp_t *ts, uint8_t hour) {

}
uint8_t ts_minute(const timestamp_t *ts) {

}
void ts_set_minute(timestamp_t *ts, uint8_t minute) {

}
uint8_t ts_second(const timestamp_t *ts) {

}
void ts_set_second(timestamp_t *ts, uint8_t second) {

}

void ts_jd2000(const timestamp_t *ts, uint32_t *jdn, uint32_t *jds) {

}






