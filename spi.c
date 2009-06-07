#include "global.h"
#include "spi.h"

void spi_init( void ) {
  sbi(PORTB, 5);  // set SCK hi
  sbi(DDRB, 5);   // set SCK as output
  cbi(DDRB, 4);   // set MISO as input
  sbi(DDRB, 3);   // set MOSI as output
  sbi(DDRB, 2);   // SS must be output for Master mode to work
  // setup SPI interface :
  // master mode
  sbi(SPCR, MSTR);
  // clock = f/4
//  cbi(SPCR, SPR0);
//  cbi(SPCR, SPR1);
  // clock = f/16
  cbi(SPCR, SPR0);
  sbi(SPCR, SPR1);
  // select clock phase positive-going in middle of data
  cbi(SPCR, CPOL);
  // Data order MSB first
  cbi(SPCR,DORD);
  // enable SPI
  sbi(SPCR, SPE);
  // reset input
  inb(SPSR);
}

void spi_exchange(char* buffer, uint16_t length) {
  uint16_t i;
  for (i = 0; i < length; ++i) {
    outb(SPDR, buffer[i]); // Start transfer
    while(!(inb(SPSR) & (1<<SPIF))); // Wait for completion
    buffer[i] = inb(SPDR);
  }
}
