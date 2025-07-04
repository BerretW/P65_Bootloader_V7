.include "io.inc65"
.include "macros_65C02.inc65"

.zeropage
_delay_lo:				.res 1
_delay_hi:				.res 1

.setcpu		"65C02"
.smart		on
.autoimport	on
.case		on
.debuginfo	off
.importzp	sp, sreg, regsave, regbank, _in_char , BANK_BASE
.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
.macpack	longbranch

.export _format_bank
.export _set_bank
.export _get_bank
.export __delay2
.export INPUT_CHK
.export _delay
.export _via_test
.export _echo_test
.export _INTE
.export _INTD
.export _GET_INT
.export _write_to_RAM

.export __chrout
.export __output
.export __print
.export __newline
.export _restart
.export _start_ram
.export _init_vec
.segment "CODE"


_init_vec:          LDA #<_IRQ_ISR
                    STA _irq_vec
                    LDA #>_IRQ_ISR
                    STA _irq_vec + 1
                    LDA #<_NMI_ISR
                    STA _nmi_vec
                    LDA #>_NMI_ISR
                    STA _nmi_vec + 1
                    RTS


__output:           JMP _acia_print_nl

__print:            JMP _acia_puts


__newline:          JMP _acia_put_newline

__chrout:           JMP _acia_putc


INPUT_CHK:    ;JMP _KBINPUT

              JSR _KBSCAN
        			BNE @prt
        			JSR _ACIA_SCAN
        			BEQ INPUT_CHK
@prt:   			rts

_set_bank:
					STA BANK_BASE
					;CLC
					;ADC #$30
					;JSR _acia_putc
					RTS
_get_bank:  LDA BANK_BASE
            RTS


_echo_test:         
@lll:               JSR _KBINPUT
                    STA _in_char
                    JSR _CHROUT
                    ;JSR _GD_cursor_RIGHT
                    JMP @lll

_restart:           PLA             ;clean stack
                    JMP _RST

_start_ram:         PLA
                    JMP (RAMDISK_RESET_VECTOR)

_via_test:	LDA #$FF
						STA VIA2_DDRA
						LDA #$55
						STA VIA2_ORA
						JSR _delay
						LDA #$AA
						STA VIA2_ORA
						JSR _delay
						JMP _via_test

via_loop:			JSR _CHRIN
						STA VIA2_ORA
						JSR _CHROUT
						JMP via_loop
; ---------------------------------------------------------------
; void __near__ print_f (char *s)
; ---------------------------------------------------------------


_format_bank:
                  LDY #0
                  LDA #<(BANKDISK)
                  LDX #>(BANKDISK)
                  STA ptr1
                  STX ptr1 + 1

@write_BANK:			LDA #$0
                  STA (ptr1), Y
                  INY
                  CPY #$0
                  BNE @end_BANK
                  INX
                  STX ptr1 + 1
                  CPX #$C0
                  BNE @end_BANK
                  RTS
@end_BANK:			  JMP @write_BANK

_GET_INT:   LDA $CF20
            RTS

_INTE:  CLI
        RTS
_INTD:  SEI
        RTS

        _write_to_RAM:
        				        LDY #0
        				        LDA #<(RAMDISK_START)
        				        LDX #>(RAMDISK_START)
        				        STA ptr1
        				        STX ptr1 + 1

        @write:			    JSR _ACIA_IN
                				;JSR _lcd_putc
                				STA (ptr1), Y
                				INY
                				CPY #$0
                				BNE @end
                				INX
                				STX ptr1 + 1
                				CPX #>(RAMDISK_END+1)
                				BNE @end
                				JMP (RAMDISK_RESET_VECTOR)
        @end:			      JMP @write




_delay:
  STA _delay_lo  ; save state
  LDA #$00
  STA _delay_hi  ; high byte
delayloop:
  ADC #01
  BNE delayloop
  CLC
  INC _delay_hi
  BNE delayloop
  CLC
  ; exit
  LDA _delay_lo  ; restore state
  RTS

__delay2:				LDX #$2
__delay3:				DEX
                BNE __delay3
                RTS
