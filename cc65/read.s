;
; int __fastcall__ read (int fd, void* buf, unsigned count);
;

.include        "microuk101.inc"

.import         popax, popptr1
.importzp       ptr1, ptr2, ptr3
.import		_get_buffered_char

.export         _read

.proc           _read 
    
        sta     ptr3
        stx     ptr3+1           ; Count in ptr3
        
        ; Setup internal loop counter in ptr2
        sta     ptr2
        stx     ptr2+1
        
        jsr     popptr1          ; Buffer address in ptr1
        jsr     popax            ; Discard fd
    
begin:  ; Check if count is zero (16-bit check)
        lda     ptr2
        ora     ptr2+1
        beq     done             ; If count is 0, return

getch:  jsr     _get_buffered_char
        cpx     #$FF             ; High byte $FF means empty
        beq     getch 
    
        and     #$7F             ; Clear top bit
        cmp     #$0D             ; Check for '\r'
        bne     putch            
        lda     #$0A             ; Replace with '\n'

putch:  ldy     #$00             
        sta     (ptr1),y         ; Put char into C return buffer
        
        pha                      ; Save character to check later
        
        ; Increment C buffer pointer
        inc     ptr1             
        bne     @dec
        inc     ptr1+1

@dec:   ; Decrement 16-bit count
        lda     ptr2
        bne     @low
        dec     ptr2+1
@low:   dec     ptr2

        ; --- THE FIX: Early Exit on Newline ---
        pla                      ; Restore character
        cmp     #$0A             ; Was it a newline?
        beq     done             ; YES: Return to C immediately
        
        jmp     begin            ; NO: Get next character

done:   ; Calculate actual bytes read for the return value
        ; Standard C 'read' should return the number of bytes processed
        lda     ptr3
        sec
        sbc     ptr2             ; Original count - remaining count
        pha
        lda     ptr3+1
        sbc     ptr2+1
        tax
        pla                      ; Result in A/X
        rts                      

.endproc

