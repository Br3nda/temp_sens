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
  
  
  uint8_t crc, checksum;
  uint16_t val;
  do {
  
    crc = 0;
    
    DATA_UP();
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("PORTD: ");
    printBin(PIND, 8);
    rprintfChar('\n');
    #endif
    
    // Send command
    humtempsens_command_init();
    uint8_t bit;
    for (bit = 0; bit < 8; bit++) {
      if (command >> 7) {
        DATA_UP();
      } else {
        DATA_DOWN();
      }
      SCK_UP();
      uint8_t txb = (command ^ crc) >> 7;
      crc <<= 1;
      crc |= txb;
      crc ^= ((txb << 4) | (txb << 5));
      SCK_DOWN();
      command <<= 1;
    }
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("Checking for chip\n");
    #endif
    
    // Check acknowledgement
    DATA_UP();
    
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("PORTD: ");
    printBin(PIND, 8);
    rprintfChar('\n');
    #endif
    
    if (PIND & (1 << PD7)) {
      rprintf("Failed to receive acknowledgement.\n");
      return -1;
    }
    
    SCK_UP();
    SCK_DOWN();
    
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("PORTD: ");
    printBin(PIND, 8);
    rprintfChar('\n');
    #endif
    
    // Wait for data ready
    while (PIND & (1 << PD7)) {}
    
    // Retrieve data
    uint8_t byte;
    for (byte = 0; byte < 2; byte++) {
      for (bit = 0; bit < 8; bit++) {
        val <<= 1;
        uint8_t in = (PIND >> PD7) & 1;
        
        val |= in;
        uint8_t txb = in ^ (crc >> 7);
        crc <<= 1;
        crc |= txb;
        crc ^= ((txb << 4) | (txb << 5));
        
        SCK_UP();
        SCK_DOWN();
      }
      
      // Acknowledge
      DATA_DOWN();
      SCK_UP();
      SCK_DOWN();
      DATA_UP();
    }
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("Received: ");
    printBin(val, 16);
    rprintfChar('\n');
    #endif

    // Retrieve checksum
    checksum = 0;
    for (bit = 0; bit < 8; bit++) {
      checksum >>= 1;
      if (PIND & (1 << PD7)) {
        checksum |= (1 << 7);
      } else {
      }
      SCK_UP();
      SCK_DOWN();
    }
    
    #ifdef HUMTEMPSENS_DEBUG
    rprintf("Calculated: ");
    printBin(crc, 8);
    rprintfChar('\n');
    rprintf("Received: ");
    printBin(checksum, 8);
    rprintfChar('\n');
    #endif
    
    if (checksum != crc) humtempsens_init();
  } while (checksum != crc);
  
  // Acknowledge
  DATA_DOWN();
  SCK_UP();
  SCK_DOWN();
  DATA_UP();
  
  return val;
}

void humtempsens_init( void ) {
  PORTD &= ~(1 << PD7);
  DDRD |= (1 << PD6);
  
  uint8_t pulses;
  for (pulses = 0; pulses < 10; pulses++) {
    SCK_UP();
    SCK_DOWN();
  }
  
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
