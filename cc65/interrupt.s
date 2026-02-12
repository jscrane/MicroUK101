.export   _irq_handler, _get_buffered_char, _has_char
.importzp ptr1

.include  "microuk101.inc"

.bss
rx_head: .res 1
rx_tail: .res 1
rx_buf:  .res 256

.segment "CODE"

_irq_handler:
    pha             ; Save A
    txa
    pha             ; Save X
    tya
    pha             ; Save Y

    lda ACIA_STATUS
    and #RDRF_MASK
    beq @exit

    lda ACIA_DATA   ; Read char (clears hardware IRQ)
    ldx rx_head
    sta rx_buf,x    ; Store in buffer
    inc rx_head     ; Advance head

@exit:
    pla
    tay             ; Restore Y
    pla
    tax             ; Restore X
    pla             ; Restore A
    rti             ; Return from Interrupt

_get_buffered_char:
    lda rx_tail
    cmp rx_head     ; Is buffer empty?
    beq @empty
    ldx rx_tail
    lda rx_buf,x    ; Get byte
    inc rx_tail     ; Advance tail
    ldx #0          ; High byte for C int
    rts
@empty:
    lda #$FF        ; Return -1
    tax
    rts

_has_char:
    lda rx_tail
    cmp rx_head
    beq @no
    lda #1
    ldx #0
    rts
@no:
    lda #0
    ldx #0
    rts

