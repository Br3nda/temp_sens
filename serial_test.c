#include "global.h"

#include <util/delay.h>
#include "uart.h"
#include "rprintf.h"

/* new style */
int main(void)
{
  uartInit();                 // initialize UART (serial port)
  uartSetBaudRate(9600);      // set UART speed to 9600 baud
  rprintfInit(uartSendByte);  // configure rprintf to use UART for output
  
  DDRC |= (1 << PC5);
   
  while (1) {
    
    int8_t byte = uartGetByte();
    
    if (byte >= 0) uartSendByte(byte);
    
    PORTC ^= (1<<PC5);
  }
  return(0);
}
