#include "global.h"
#include <util/delay_basic.h>

#include "humtempsens.h"
#include "sensor.h"
#include "rprintf.h"

#define DATA_UP() {DDRD &= ~(1 << PD7); _delay_loop_1(10);}
#define DATA_DOWN() {DDRD |= (1 << PD7); _delay_loop_1(10);}
#define SCK_UP() {PORTD |= (1 << PD6); _delay_loop_1(10);}
#define SCK_DOWN() {PORTD &= ~(1 << PD6); _delay_loop_1(10);}

#define MEASURE_TEMPERATURE 3
#define MEASURE_HUMIDITY 5
#define HUMTEMPSENS_RESET 30;

static inline void humtempsens_command_init( void ) {
  DATA_UP();
  SCK_UP();
  DATA_DOWN();
  SCK_DOWN();
  SCK_UP();
  DATA_UP();
  SCK_DOWN();
}

static inline void printBin (uint16_t input, uint8_t bits) {
  while (bits--) {
    if (input & (1 << bits)) {
      rprintfChar('1');
    } else {
      rprintfChar('0');
    }
  }
}

static inline int16_t humtempsens_measure(uint8_t command) {
  humtempsens_command_init();
  
//  uint8_t crc = 0;
  uint8_t bit;
  for (bit = 0; bit < 8; bit++) {
    if (command >> 7) {
      DATA_UP();
    } else {
      DATA_DOWN();
    }
    SCK_UP();
//    uint8_t txb = (command ^ crc) >> 7;
//     crc <<= 1;
//     crc |= txb;
//     crc ^= ((txb << 4) | (txb << 5));
    SCK_DOWN();
    command <<= 1;
  }
  
  // Check acknowledgement
  DATA_UP();
  if (PIND & (1 << PD7)) {
    rprintf("Failed to receive acknowledgement.\n");
    return -1;
  }
  
  SCK_UP();
  SCK_DOWN();
  
  // Wait for data ready
  while (PIND & (1 << PD7)) {}
  
  // Retrieve data
  uint8_t byte;
  uint16_t val = 0;
  for (byte = 0; byte < 2; byte++) {
    for (bit = 0; bit < 8; bit++) {
      SCK_UP();
      SCK_DOWN();
      val <<= 1;
      uint8_t in = (PIND >> PD7) & 1;
      
      val |= in;
//      uint8_t txb = in ^ (crc >> 7);
//       crc <<= 1;
//       crc |= txb;
//       crc ^= ((txb << 4) | (txb << 5));
    }
    
    // Acknowledge
    DATA_DOWN();
    SCK_UP();
    SCK_DOWN();
    DATA_UP();
  }

// Checksum calculation is currently not working
  // Retrieve checksum
  uint8_t checksum = 0;
//   rprintf("Checksum: ");
  for (bit = 0; bit < 8; bit++) {
    SCK_UP();
    SCK_DOWN();
    checksum <<= 1;
    if (PIND & (1 << PD7)) {
      checksum |= 1;
//       rprintfChar('1');
    } else {
//       rprintfChar('0');
    }
  }
//   rprintfChar('\n');
  
  return val;
}

void humtempsens_init( void ) {
  PORTD &= ~(1 << PD7);
  DDRD |= (1 << PD6);
  
  humtempsens_command_init();
  
  uint8_t command = HUMTEMPSENS_RESET;
  uint8_t bit;
  for (bit = 0; bit < 8; bit++) {
    if (command >> 7) {
      DATA_UP();
    } else {
      DATA_DOWN();
    }
    SCK_UP();
    SCK_DOWN();
    command <<= 1;
  }
  
  SCK_UP();
  SCK_DOWN();
  
}

humtempdata get_hum_temp( void ) {
  humtempdata data;
  
  data.temperature = humtempsens_measure(MEASURE_TEMPERATURE);
  
  data.humidity = humtempsens_measure(MEASURE_HUMIDITY);
  
  return data;
}
