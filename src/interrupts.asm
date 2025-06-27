
.setcpu		"65C02"
.smart		on
.autoimport	on
.case		on

.export _IRQ_ISR
.export _NMI_ISR


.segment "CODE"

_NMI_ISR:
                  RTI


_IRQ_ISR:         SEI
                  
                  BEQ @end

@end:             CLI
                  RTI
