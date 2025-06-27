#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utils.h"
#include "jumptable.h"
#include "ewoz.h"
#include "pckybd.h"
#include "acia.h"
#include "vera.h"
//#define KEYBOARD;
//#define GAMEDUINO;
//#define FULL;
#define SERIAL;
#define VERA;

void setup(){
  int videomode = 1; //0 = disable 1 = vga 2 = composite
  init_vec();
  #if defined(SERIAL) || defined (FULL)
    ACIAINIT();
  #endif
  #if defined(KEYBOARD) || defined (FULL)
    KBINIT();
  #endif
  #if defined(VERA) || defined (FULL)
    VERAINIT(videomode);
  #endif
}


void main(void) {
  char c;
  char i;
  int x ;
  char * m0 = "APPARTUS PROJEKT65 Bootloader SE 10.0b HW10-2-1";
  char * m1 = "w for start write to RAM";
  char * m2 = "m for start monitor";
  //INTDI();
  //setup();



#if defined (SERIAL)
acia_print_nl(m0);
acia_print_nl(m1);
acia_print_nl(m2);
#endif

  while(1){
    #if defined (KEYBOARD) || defined (FULL)
      c = CHRIN();
    #endif
    #if defined (SERIAL)
      c = acia_getc();
    #endif

    switch (c){
      case 'm':
        EWOZ();
      break;

      case 'w':
      acia_print_nl("writing to RAM");
      write_to_RAM();
      break;

      case 't':
        ++i;
        if (i >= 16) i = 0;
      break;

      case 'v':
        via_test();
      break;

      case 'e':
        echo_test();
      break;

      case 0x12:
        restart();
      break;

      case 's':
        start_ram();
      break;
      case '1':
        VERAL0ENABLE();
      break;
       case '2':
        VERAL1ENABLE();
      break;
      case '0':
        VERAL0DISABLE();
        VERAL1DISABLE();
      break;
      case 0x03:
      break;

      default:

      break;
    }


  }
}
