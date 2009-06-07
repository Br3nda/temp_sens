#ifndef PARSER_H
#define PARSER_H

#define eof ((char*) 0)

void parser_init( void );
int received( char* data, uint8_t len );

#endif