#include "global.h"
#include "parser.h"

#include "rprintf.h"

char thingBuffer[50];
uint8_t thingBufferCount;
uint8_t numericVal;

%%{
  machine test_parser;
  
  action RecordThing {
    thingBuffer[thingBufferCount++] = *p;
  }
  
  action GiveThing {
    thingBuffer[thingBufferCount++] = 0;
    rprintf("I has a ");
    rprintfStr(thingBuffer);
    rprintfChar('\n');
    thingBufferCount = 0;
  }
  
  action HandleError {
    rprintf("Oh nose no sense %d!\n", cs);
    fgoto main;
  }
  
  action ShowState {
    rprintf("State %d\n", cs);
  }
  
  action ReadHex {
    numericVal = (numericVal << 4) | ((*p >= 'a' ? *p - ('a' - 10) : *p - '0') & 15);
  }
  
  action SetOut {
    PORTC = numericVal;
  }
  
  gimmeh =
    (
      'GIMMEH '
      ((any $RecordThing)* :> '\n')
    ) @GiveThing;
  
  output = ('OUT C ' ([0-9a-f] @ReadHex [0-9a-f] @ReadHex) '\n') @SetOut;
  
  command = gimmeh | output | '\n';
  
  main := (command $!HandleError)*;
}%%

%% write data;

int cs;

void parser_init( void ) {
  thingBufferCount = 0;
  %% write init;
}

int received( char* data, uint8_t len )
{
  char *p = data;
  char *pe = data + len;
  %% write exec;
  return 0;
}
