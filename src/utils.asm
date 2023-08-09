
;------------------------------------------------------------------------------
; Utils 

getRegister:

; IN A > Register to read 
; OUT A < Value of Register 
    
    push    bc                                  ; save BC 
    ld      bc, TBBLUE_REGISTER_SELECT_P_243B
    out     (c), a 
    inc     b 
    in      a, (c) 
    pop     bc 
    ret 


saveBankSlot: 
; Saves the slot in A to the buffer 
; IN A > SLOT to save, 0-7 
; OUT nothing 
; USES : hl, a 

    ld      hl, slotBuffers
    add     hl, a 
    add     $50         
    call    getRegister
    ld      (hl), a 
    ret 

restoreBankSlot: 
; Restores the buffer to SLOT 
; IN A > SLOT to save, 0-7 
; OUT nothing 
; USES : hl, a 

    ld      hl, slotBuffers
    add     hl, a
    add     $50 
    ld      (.bank+2), a 
    ld      a, (hl)      
.bank: 
    nextreg $50, a 
    ret 


slotBuffers:
    ds      7, 0 


; Count string 
; IN HL > pointer to zero term string
; OUT A < length of string 

count_str_length:

        ; hl is set 
        ld      b, 0 
        xor     a
.keep_counting:
        cp      (hl)
        jr      z, .no_size 
        inc     hl 
        inc     b 
        jr      nz, .keep_counting
.no_size:
        or      a 
        ld      a, b            ; size max = 255 
        ret 

print_rst16:    ; prints string in HL terminated with 0 
	    ld a,(hl):inc hl:or a:ret z:rst 16:jr print_rst16