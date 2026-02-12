.export   _init
.import   _main, zerobss, copydata, initlib, donelib
.import   __RAM_START__, __RAM_SIZE__
.import   _irq_handler

.include  "zeropage.inc"
.include  "microuk101.inc"

.segment "STARTUP"

_init:
    sei             ; Disable interrupts during setup
    cld             ; 6502 hygiene
    ldx #$FF
    txs             ; Hardware stack at $01FF

    ; --- Redirect Monitor IRQ to our Assembly Handler ---
    lda #<_irq_handler
    sta OSI_IRQ_HOOK
    lda #>_irq_handler
    sta OSI_IRQ_HOOK+1

    ; --- Initialize CC65 Parameter Stack ---
    lda #<(__RAM_START__ + __RAM_SIZE__)
    sta sp
    lda #>(__RAM_START__ + __RAM_SIZE__)
    sta sp+1

    ; --- CC65 Runtime Setup ---
    jsr zerobss     ; Clear global variables
    jsr copydata    ; Initialize DATA segment
    jsr initlib     ; Run C constructors

    cli             ; ENABLE INTERRUPTS for UART
    jsr _main       ; Call C code

_exit:
    sei             ; Disable interrupts so your ISR stops
    jsr donelib     ; Run C destructors
    jmp NEWMON      ; JUMP TO MONITOR (Replace $FF00 with your ROM's entry)

.segment "VECTORS"
; We leave this empty because your ROM handles $FFFA-$FFFF.
; We only hook the RAM addresses in _init above.

