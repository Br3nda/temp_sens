#include "global.h"

#include <util/delay.h>
#include "uart.h"
#include "rprintf.h"
#include "parser.h"

/* new style */
int main(void)
{
  uartInit();                 // initialize UART (serial port)
  uartSetBaudRate(9600);      // set UART speed to 9600 baud
  rprintfInit(uartSendByte);  // configure rprintf to use UART for output
  
  parser_init();
  
  DDRC |= (1<<PC0 | 1<<PC1 | 1<<PC2 | 1<<PC3 | 1<<PC4 | 1<<PC5);
  PORTC = 0;
  
  char buffer[32];
  uint8_t buffered = 0;
  while (1) {
    int8_t byte;
    char success = uartReceiveByte(&byte);
    
    if (success == TRUE && byte > 0) {
      buffer[buffered++] = byte;
      if (buffered == 32) {
        received(buffer, buffered);
        buffered = 0;
      }
    } else if (buffered) {
      received(buffer, buffered);
      buffered = 0;
    }
    
  }
  return(0);
}
