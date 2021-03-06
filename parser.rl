#include "global.h"
#include "parser.h"

#include "rprintf.h"
#include "sensor.h"

uint8_t numericVal;
char dataBuffer[255];
uint8_t dataLength;

%%{
  machine test_parser;
  
  action HandleError {
    rprintf("Invalid input in state %d!\n", cs);
    fgoto main;
  }
  
  action ReadHex {
    numericVal = (numericVal << 4) | ((*p >= 'a' ? *p - ('a' - 10) : *p - '0') & 15);
  }
  
  action SetOut {
    PORTC = numericVal;
  }
  
  action SetMask {
    DDRC = numericVal;
  }
  
  action ReadPort {
    rprintf("DATA C ");
    rprintfu08(PINC);
    rprintfChar('\n');
  }
  
  action GetData {
    send_data();
  }
  
  action ResetDataBuffer {
    dataLength = 0;
  }
  
  action AppendDataByte {
    dataBuffer[dataLength++] = numericVal;
  }
  
  action SpiExchange {
    uart2spi(dataBuffer, dataLength);
  }
  
  get_data = 'FETCH\n' @GetData;
  
  output = ('OUT C ' ([0-9a-f] @ReadHex [0-9a-f] @ReadHex) '\n') @SetOut;
  mask = ('MASK C ' ([0-9a-f] @ReadHex [0-9a-f] @ReadHex) '\n') @SetMask;
  read = 'READ C\n' @ReadPort;
  spi = ('SPI ' @ResetDataBuffer (([0-9a-f] @ReadHex [0-9a-f] @ReadHex) @AppendDataByte)* '\n') @SpiExchange;
  
  command = get_data | output | mask | read | spi | '\n';
  
  main := (command $!HandleError)*;
}%%

%% write data;

int cs;

void parser_init( void ) {
  %% write init;
}

int received( char* data, uint8_t len )
{
  char *p = data;
  char *pe = data + len;
  %% write exec;
  return 0;
}
