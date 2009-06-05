#ifndef PARSER_H
#define PARSER_H

#define eof -1

void parser_init( void );
int received( char* data, uint8_t len );

#endif