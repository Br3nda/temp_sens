#include "global.h"
#include "parser.h"

#include "rprintf.h"

char thingBuffer[50];
uint8_t thingBufferCount;

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
  
  command = 'GIMMEH '
    ((any $RecordThing)* :> '\n');
  
  main := (command @GiveThing $!HandleError)*;
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
