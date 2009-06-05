# makefile, written by guido socher
MCU=atmega8
#MCU=at90s4433
CC=avr-gcc
OBJCOPY=avr-objcopy
# optimize for size:
CFLAGS=-g -mmcu=$(MCU) -Wall -Wstrict-prototypes -Os -mcall-prologues
TARGET=serial_test
PROGRAMMER=avrusb500
MICRO=m8
#-------------------
all: ${TARGET}.hex parser.ps
#-------------------
help: 
	@echo "Usage: make all|load|load_pre|rdfuses|wrfuse1mhz|wrfuse4mhz|wrfusecrystal"
	@echo "Warning: you will not be able to undo wrfusecrystal unless you connect an"
	@echo "         external crystal! uC is dead after wrfusecrystal if you do not"
	@echo "         have an external crystal."
#-------------------
%.hex: %.out
	$(OBJCOPY) -R .eeprom -O ihex $< $@
serial_test.out: serial_test.o buffer.o uart.o rprintf.o parser.o
	$(CC) $(CFLAGS) -o $@ -Wl $^
%.o: %.c
	$(CC) $(CFLAGS) -Os -c $<
parser.c: parser.rl
	ragel -G2 -o $@ $<
parser.ps: parser.rl
	ragel -Vp $< | dot -Tps -o $@
#------------------
load: ${TARGET}.hex
	avrdude -p ${MICRO} -c ${PROGRAMMER} -e -U flash:w:${TARGET}.hex
#
#-------------------
# fuse byte settings:
#  Atmel AVR ATmega8 
#  Fuse Low Byte      = 0xe1 (1MHz internal), 0xe3 (4MHz internal), 0xe4 (8MHz internal)
#  Fuse High Byte     = 0xd9 
#  Factory default is 0xe1 for low byte and 0xd9 for high byte
# Check this with make rdfuses
rdfuses:
	avrdude -p ${MICRO} -c ${PROGRAMMER} -v -q
# use internal RC oscillator 1 Mhz
wrfuse1mhz:
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U lfuse:w:0xe1:m
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U hfuse:w:0xd9:m
# use internal RC oscillator 4 Mhz
wrfuse4mhz:
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U lfuse:w:0xe4:m
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U hfuse:w:0xd9:m
# use external 3-8 Mhz crystal
# Warning: you can not reset this to intenal unless you connect a crystal!!
wrfusecrystal:
	@echo "Warning: The external crystal setting can not be changed back without a working crystal"
	@echo "         You have 3 seconds to abort this with crtl-c"
	@sleep 3
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U lfuse:w:0xee:m
	avrdude -p ${MICRO} -c ${PROGRAMMER} -u -v -U hfuse:w:0xd9:m
#-------------------
clean:
	rm -f *.o *.map *.out *t.hex parser.c parser.ps
#-------------------
