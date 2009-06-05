#include "global.h"
#include "parser.h"

#include "rprintf.h"
#include "sensor.h"

uint8_t numericVal;

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
  
  action GetData {
    send_data();
  }
  
  get_data = 'FETCH\n' @GetData;
  
  output = ('OUT C ' ([0-9a-f] @ReadHex [0-9a-f] @ReadHex) '\n') @SetOut;
  
  command = get_data | output | '\n';
  
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
