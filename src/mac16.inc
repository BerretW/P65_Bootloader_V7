;----------------------------------------------------------------------
; Commander X16 KERNAL 16 Bit Macros
;----------------------------------------------------------------------
; (C)2020 Michael Steil, License: 2-clause BSD
; based on GEOS 64, edited by Maciej 'YTM/Alliance' Witkowiak


; Makro LoadB zapisuje hodnotu do určité paměťové lokace. Pokud je hodnota konstantní a je rovna 0, 
; používá se instrukce 'stz' pro nastavení destinace na nulu. Jinak se hodnota načte do akumulátoru
; a pak se uloží do destinace.
.macro LoadB dest, value
	.if .const(value) .and value=0
		stz dest
	.else
		lda #value
		sta dest
	.endif
.endmacro

; Makro LoadW funguje podobně jako LoadB, ale pracuje s celými slovy (16 bitů) místo bajtů. 
; To znamená, že hodnoty jsou uloženy v paměti po bytech.
.macro LoadW dest, value
	.if .const(value) .and .lobyte(value)=0
		stz dest
	.else
		lda #<(value)
		sta dest
	.endif
	.if .const(value) .and .hibyte(value)=0
		stz dest+1
	.else
		.if (.not .const(value)) .or (>(value))<>(<(value))
			lda #>(value)
		.endif
		sta dest+1
	.endif
.endmacro

; Makro MoveB kopíruje bajt z jedné paměťové lokace do jiné.
.macro MoveB source, dest
	lda source
	sta dest
.endmacro

; Makro MoveW kopíruje slovo (dva bajty) z jedné paměťové lokace do jiné.
.macro MoveW source, dest
	MoveB source+0, dest+0
	MoveB source+1, dest+1
.endmacro

; Makro add provádí sčítání pomocí akumulátoru.
.macro add source
	clc
	adc source
.endmacro

; Makro AddB přičítá hodnotu zdroje k hodnotě v destinaci a výsledek uloží zpět do destinace.
.macro AddB source, dest
	lda source
	add dest
	sta dest
.endmacro

; Makro AddW je stejné jako AddB, ale pracuje se slovy namísto bajtů.
.macro AddW source, dest
	AddB source+0, dest+0
	lda source+1
	adc dest+1
	sta dest+1
.endmacro


.macro AddW3 source1, source2, dest
	lda source1
	clc
	adc source2
	sta dest
	lda source1+1
	adc source2+1
	sta dest+1
.endmacro

.macro AddVB value, dest
	lda dest
	clc
	adc #value
	sta dest
.endmacro

.macro AddVW value, dest
	.local j
	lda dest
	clc
	adc #<(value)
	sta dest
	.if (>(value))=0
		bcc j
		inc dest+1
		j:
	.else
		lda dest+1
		adc #>(value)
		sta dest+1
	.endif
.endmacro

.macro sub source
	sec
	sbc source
.endmacro

; Makro SubB odečítá hodnotu zdroje od hodnoty v destinaci a výsledek uloží zpět do destinace.
.macro SubB source, dest
	lda dest
	sub source
	sta dest
.endmacro

; Makro SubW je stejné jako SubB, ale pracuje se slovy namísto bajtů.
.macro SubW source, dest
	SubB source+0, dest+0
	lda dest+1
	sbc source+1
	sta dest+1
.endmacro

.macro SubVW value, dest
	.local j
	lda dest+0
	sec
	sbc #<(value)
	sta dest+0

	.if (>(value))=0
		bcs j
		dec dest+1
		j:
	.else
		lda dest+1
		sbc #>(value)
		sta dest+1
	.endif
.endmacro

; Makro CmpB porovnává hodnoty v zdroji a destinaci a nastavuje procesorové příznaky podle výsledku.
.macro CmpB source, dest
	lda source
	cmp dest
.endmacro

.macro CmpBI source, immed
	lda source
	cmp #immed
.endmacro

.macro CmpW source, dest
	.local @j
	CmpB source+1, dest+1
	bne @j
	CmpB source+0, dest+0
@j:
.endmacro

.macro CmpWI source, immed
	.local @j
	CmpBI source+1, >(immed)
	bne @j
	CmpBI source+0, <(immed)
@j:
.endmacro

; Makro PushB ukládá hodnotu z akumulátoru na vrchol zásobníku.
.macro PushB source
	lda source
	pha
.endmacro

.macro PushW source
	PushB source+0
	PushB source+1
.endmacro

; Makro PopB načte hodnotu z vrcholu zásobníku do akumulátoru.
.macro PopB dest
	pla
	sta dest
.endmacro

.macro PopW dest
	PopB dest+1
	PopB dest+0
.endmacro

.macro smb bitN, dest
	pha
	smbf bitN, dest
	pla
.endmacro

.macro smbf bitN, dest
	lda #1 << bitN
	.ifp02
		ora dest
		sta dest
	.else
		tsb dest
	.endif
.endmacro

.macro rmb bitN, dest
	pha
	rmbf bitN, dest
	pla
.endmacro

.macro rmbf bitN, dest
	.ifp02
		lda #(1 << bitN) ^ $ff
		and dest
		sta dest
	.else
		lda #1 << bitN
		trb dest
	.endif
.endmacro

.macro bbs bitN, source, addr
	.local @j
	php
	pha
	lda source
	and #1 << bitN
	beq @j
	pla
	plp
	bra addr
@j:
	pla
	plp
.endmacro

.macro bbsf bitN, source, addr
	.if (bitN = 7)
		bit source
		bmi addr
	.else
		.if (bitN = 6)
			bit source
			bvs addr
		.else
			lda source
			and #1 << bitN
			bne addr
		.endif
	.endif
.endmacro

.macro bbr bitN, source, addr
	.local @j
	php
	pha
	lda source
	and #1 << bitN
	bne @j
	pla
	plp
	bra addr
@j:
	pla
	plp
.endmacro

.macro bbrf bitN, source, addr
	.if (bitN = 7)
		bit source
		bpl addr
	.else
		.if (bitN = 6)
			bit source
			bvc addr
		.else
			lda source
			and #1 << bitN
			beq addr
		.endif
	.endif
.endmacro

.macro addv value
	clc
	adc #value
.endmacro

.macro subv value
	sec
	sbc #value
.endmacro

.macro bnex addr
	txa
	bne addr
.endmacro

.macro beqx addr
	txa
	beq addr
.endmacro

.ifp02
	.macro bra addr
		jmp addr
	.endmacro
.endif

.macro IncW addr
	.local @j
	inc addr
	bne @j
	inc addr+1
	@j:
.endmacro

.macro DecW_ addr
	.local @j
	lda addr
	bne @j
	dec addr+1
@j:	dec addr
.endmacro

.macro DecW addr
	DecW_ addr
	lda addr
	ora addr+1
.endmacro
