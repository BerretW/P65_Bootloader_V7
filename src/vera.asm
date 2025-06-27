
          .setcpu		"65C02"
          .smart		on
          .autoimport	on


        .include "io.inc65"
		.include "macros_65C02.inc65"
		.include "zeropage.inc65"
        .zeropage

       


        .importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
        .globalzp tmpstack

        .export _vera_init
        .export _vera_reset
        .export _vera_vga
        .export _change_output_mode
        .export _change_current_field_disable
        .export _change_current_field_enable
        .export _change_sprites_disable
        .export _change_sprites_enable
        .export _change_layer1_disable
        .export _change_layer1_enable
        .export _change_layer0_disable
        .export _change_layer0_enable

                   

        .code
; void VERA_init()
; Initialize the vera chip in vga mode

_vera_init:         
                    JSR _change_output_mode
                    JSR _change_layer1_enable
                    rts

_vera_reset:
    LDA #$80
    STA VERA_CTRL
    RTS

_vera_vga:
    LDA #$01
    JSR _change_output_mode
    RTS

_vera_test:
  LDA #$10
  STA VERA_ADDRx_L
  LDA #$00
  STA VERA_ADDRx_M
  STA VERA_ADDRx_H
  LDX #0
LOOP:
  TXA
  STA VERA_DATA0
  LDA #$6E
  STA VERA_DATA0
  INX
  BNE LOOP

  LDY #10
LOOP2:
  LDA #$20
  STA VERA_DATA0
  LDA #$6E
  STA VERA_DATA0
  INX
  BNE LOOP2

  RTS
; Umožňuje změnit stav 'Current Field'
; @in A (value) - 0 = vypnuto, 1 = zapnuto
_change_current_field_disable:
    LDA #0
    JMP _change_current_field
_change_current_field_enable:
    LDA #1
_change_current_field:
    PHA
    LDA VERA_DC_VIDEO
    AND #$7F  ; Mask to clear bit 7
    TAY
    PLA
    ROL       ; Shift to position 7
    ROL
    ROL
    ROL
    ROL
    ROL
    ROL
    ROL
    STA tmp1   ; Temporarily store the shifted value
    TYA
    ORA tmp1   ; OR the masked value from the register with the shifted input
    STA VERA_DC_VIDEO
    RTS

; Umožňuje změnit stav 'Sprites Enable'
; @in A (value) - 0 = vypnuto, 1 = zapnuto
_change_sprites_disable:
    LDA #0
    JMP _change_sprites
_change_sprites_enable:
    LDA #1
_change_sprites:
    PHA
    LDA VERA_DC_VIDEO
    AND #$BF  ; Mask to clear bit 6
    TAY
    PLA
    ROL       ; Shift to position 6
    ROL
    ROL
    ROL
    ROL
    ROL
    STA tmp1   ; Temporarily store the shifted value
    TYA
    ORA tmp1   ; OR the masked value from the register with the shifted input
    STA VERA_DC_VIDEO
    RTS

; Umožňuje změnit stav 'Layer1 Enable'
; @in A (value) - 0 = vypnuto, 1 = zapnuto
_change_layer1_disable:
    LDA #0
    JMP _change_layer1
_change_layer1_enable:
    LDA #1
_change_layer1:
    PHA
    LDA VERA_DC_VIDEO
    AND #$DF  ; Mask to clear bit 5
    TAY
    PLA
    ROL       ; Shift to position 5
    ROL
    ROL
    ROL
    ROL
    STA tmp1   ; Temporarily store the shifted value
    TYA
    ORA tmp1   ; OR the masked value from the register with the shifted input
    STA VERA_DC_VIDEO
    RTS
; Umožňuje změnit stav 'Layer1 Enable'
; @in A (value) - 0 = vypnuto, 1 = zapnuto
_change_layer0_disable:
    LDA #0
    JMP _change_layer0
_change_layer0_enable:
    LDA #1
_change_layer0:
    PHA
    LDA VERA_DC_VIDEO
    AND #$EF  ; Mask to clear bit 4
    TAY
    PLA
    ROL       ; Shift to position 4
    ROL
    ROL
    ROL
    STA tmp1   ; Temporarily store the shifted value
    TYA
    ORA tmp1   ; OR the masked value from the register with the shifted input
    STA VERA_DC_VIDEO
    RTS

; Umožňuje změnit 'Output Mode'
; @in A (mode) - mode to set (0 = off, 1 = VGA, 2 = Composite, 3 = RGB)
_change_output_mode:
    PHA                   ; Push A to the stack
    LDA VERA_DC_VIDEO     ; Load the value at address VERA_DC_VIDEO into A
    AND #$FC              ; Clear bits 0 and 1
    STA tmp1               ; Store the masked value temporarily
    PLA                   ; Pop A from the stack
    AND #$03              ; Ensure only bits 0 and 1 are used
    ORA tmp1             ; Combine the values
    STA VERA_DC_VIDEO     ; Store the result back at address VERA_DC_VIDEO
    RTS                   ; Return from subroutine