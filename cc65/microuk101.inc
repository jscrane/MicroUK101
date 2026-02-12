;
; MicroUK101
;

NEWMON	:= $FE00	; reset entry to m/c monitor
OUTPUT	:= $FF9B	; general output routine
INPUT	:= $FB46	; BASIC input routine

; 6850 ACIA Addresses
ACIA_STATUS = $F000
ACIA_DATA   = $F001

; ACIA Status Bit 0: Receiver Data Register Full (RDRF)
; 1 = Character waiting, 0 = Empty
RDRF_MASK   = %00000001

