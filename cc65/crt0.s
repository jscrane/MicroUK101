.export   _init
.import   _main, zerobss, copydata, initlib, donelib
.import   __RAM_START__, __RAM_SIZE__

.include  "zeropage.inc"
.include  "microuk101.inc"

.segment "STARTUP"

_init:
    sei             ; Disable interrupts during setup
    cld             ; 6502 hygiene
    ldx #$FF
    txs             ; Hardware stack at $01FF

    ; --- Initialize CC65 Parameter Stack ---
    lda #<(__RAM_START__ + __RAM_SIZE__)
    sta sp
    lda #>(__RAM_START__ + __RAM_SIZE__)
    sta sp+1

    ; --- CC65 Runtime Setup ---
    jsr zerobss     ; Clear global variables
    jsr copydata    ; Initialize DATA segment
    jsr initlib     ; Run C constructors

    jsr _main       ; Call C code

_exit:
    jsr donelib     ; Run C destructors
    jmp NEWMON      ; jump to monitor
