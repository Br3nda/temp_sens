#ifndef HUMTEMPSENS_H
#define HUMTEMPSENS_H

typedef struct humtempdata {
  uint16_t temperature;
  uint16_t humidity;
} humtempdata;

void humtempsens_init( void );
humtempdata get_hum_temp( void );

#endif
