.include "microuk101.inc"

.export _clrscr, _gotoxy, _cputc, _cputs, _cgetc, _kbhit, _textcolor, _cputcxy
.importzp sp, tmp1, ptr1
.import popa

; ASCII Constants
CHAR_ESC   = $1B
CHAR_LBRKT = '['
CHAR_SEMI  = ';'

.segment "CODE"

; -----------------------------------------------------------
; void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c);
; c is in A
; y is at stack top (sp)
; x is next on stack (sp+1)
; -----------------------------------------------------------
_cputcxy:
    pha                 ; Save the character (A) for later

    jsr popa            ; Pop Y coordinate from cc65 argument stack into A
    tax                 ; Move Y to X register (prep for gotoxy call)

    jsr popa            ; Pop X coordinate from cc65 argument stack into A
    ; Now A = X-coord, X = Y-coord

    jsr _gotoxy         ; Position the cursor

    pla                 ; Restore the character into A
    jmp _cputc          ; Tail-call cputc to print it and return

_cgetc:
    jsr INPUT
    rts

_kbhit:
    lda ACIA_STATUS
    and #$01
    ldx #0
    rts

_cputc:
    jsr OUTPUT
    rts

_clrscr:
    lda #CHAR_ESC
    jsr OUTPUT
    lda #CHAR_LBRKT
    jsr OUTPUT
    lda #'2'
    jsr OUTPUT
    lda #'J'
    jsr OUTPUT
    lda #CHAR_ESC
    jsr OUTPUT
    lda #CHAR_LBRKT
    jsr OUTPUT
    lda #'H'
    jsr OUTPUT
    rts

; -----------------------------------------------------------
; void __fastcall__ cputs (const char* s);
; String pointer is in A/X (A=low, X=high)
; -----------------------------------------------------------
_cputs:
    sta ptr1            ; Store string pointer low byte
    stx ptr1+1          ; Store string pointer high byte
    ldy #$00            ; Initialize index to 0

@loop:
    lda (ptr1),y        ; Get char
    beq @done           ; Exit if 0

    sty tmp1            ; Save Y in a spare ZP byte (defined in zeropage.inc)
    jsr _cputc          ; Call output (A already contains the char)
    ldy tmp1            ; Restore Y

    iny
    bne @loop
    inc ptr1+1
    jmp @loop

@done:
    rts

_gotoxy:
    pha             ; save Y param
    lda #CHAR_ESC
    jsr OUTPUT
    lda #CHAR_LBRKT
    jsr OUTPUT

    pla
    clc
    adc #1
    jsr PRDEC       ; Print Y

    lda #CHAR_SEMI
    jsr OUTPUT

    jsr popa
    clc
    adc #1
    jsr PRDEC       ; Print X

    lda #'H'
    jsr OUTPUT
    rts

; --- Helper: Print A (0-99) as Decimal ---
PRDEC:
    ldx #0          ; Count tens
@lp:
    cmp #10
    bcc @digit2     ; If A < 10, we are done with tens
    sec
    sbc #10
    inx
    jmp @lp
@digit2:
    pha             ; Save units
    txa             ; Get tens
    ora #$30        ; To ASCII
    jsr OUTPUT
    pla             ; Get units
    ora #$30        ; To ASCII
    jsr OUTPUT
    rts

_textcolor:
    ; A = cc65 color (0-15)
    cmp #8          ; Is it a "bright" color?
    bcc @standard

    pha             ; Save bright color
    ; Send ESC [ 1 ;
    lda #CHAR_ESC
    jsr OUTPUT
    lda #CHAR_LBRKT
    jsr OUTPUT
    lda #'1'
    jsr OUTPUT
    lda #CHAR_SEMI
    jsr OUTPUT
    pla             ; Get color back
    sec
    sbc #8          ; Normalize to 0-7
    jmp @print_color

@standard:
    pha
    ; Send ESC [ 0 ; (Reset bold first, then set color)
    lda #CHAR_ESC
    jsr OUTPUT
    lda #CHAR_LBRKT
    jsr OUTPUT
    lda #'0'
    jsr OUTPUT
    lda #CHAR_SEMI
    jsr OUTPUT
    pla

@print_color:
    clc
    adc #30         ; Map 0-7 to 30-37
    jsr PRDEC       ; Your decimal printer
    lda #'m'
    jsr OUTPUT
    rts
