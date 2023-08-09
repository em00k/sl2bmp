
convert_palette: 
         
        ; first get the l2 palette and store in pal_nxt_buffer 

        nextreg PALETTE_CONTROL_NR_43, %00010000	; ensure L2 palette is selected 
        nextreg $40,0 								; move to index 0 
        ld 		hl, pal_nxt_buffer

        ld 		b, 0
        ld 		c, 0 
.col_loop
        ld 		a, $41
        call 	getRegister
        ld 		(hl), a 
        inc 	hl
        ld 		a, $44
        call 	getRegister
        ld 		(hl), a 
        inc 	hl 
        inc 	c 
        ld		a, c 
        nextreg $40,a
        djnz 	.col_loop

        ld 		b, 0 ; 256 colours 
        ld 		ix, pal_nxt_buffer
        ld 		hl, pal_rgb_buffer
         
.conver_loop:
         
        push 	bc 
        ; now convert 332 to 24bit RGB
        ; I couldn't get 333 to 24bit RGB working yet

        ld 		a, (ix+0)
        ;sla 	a				; hb << 1 
        ;ld 	b, a 			; store in b 
        ;ld 	a, (ix+1)		; get hb
        ;xor 	b 				; a = byteinH<<1 xor byteinL 
        ld 		c, a 	; save a 
    
; 8 bit 
; blue 
        ld 		a, c 						; get back next palette 
        exx 	; swap to spare regs 
        ld 		hl, LUT2BITTO8BIT
        and 	3 
        add 	hl, a 
        ld 		a, (hl)

        exx 	; swap back to palette regs 
        ld 		(hl), a 					; store value 
        inc 	hl							; move to green
        

; green 
        ld 		a, c 						; get back next palette 
        exx 									; shadow regs
        ld 		hl, LUT3BITTO8BIT			; new lookup table 
        srl a 			
        srl a 										; >> 2
        and 	7 
        add 	hl, a 
        ld 		a, (hl)						; get value 

        exx 										; swap regs 
        ld 		(hl), a 					; store green 
        inc 	hl							; move to blue 
;

; red 
        ld 		a, c 						; get back next palette 
        exx 	; swap regs 

        ld 		hl, LUT3BITTO8BIT			; lookup table 
        ld 		b, 5 						;  >> 5 
        ld 		d, 0 
        ld 		e, a 						; 
        bsrl 	de,b						; 
        ld 		a, e 
        add 	hl, a 
        ld 		a, (hl)

        exx 									; back to palette regs 
        ld 		(hl), a 					; store 
        inc 	hl	
; 8bit end 

; ; 9bit 


; ; blue 
; 		ld 				a, c 						; get back next palette 
; 		exx 			; swap to spare regs 
; 		ld 				hl, LUT3BITTO8BIT
; 		and 			7 
; 		add 			hl, a 
; 		ld 				a, (hl)

; 		exx 			; swap back to palette regs 
; 		ld 				(hl), a 					; store value 
; 		inc 			hl							; move to green
        

; ; green 
; 		ld 				a, c 						; get back next palette 
; 		srl a 
; 		exx 										; shadow regs
; 		ld 				hl, LUT3BITTO8BIT			; new lookup table 
; 		ld 				b, 3
; 		ld 				d,(ix+1)
; 		ld 				e,a
; 		bsrl 			de, b 
; 		ld 				a, e 
; 		and 			7 
; 		add 			hl, a 
; 		ld 				a, (hl)						; get value 

; 		exx 										; swap regs 
; 		ld 				(hl), a 					; store green 
; 		inc 			hl							; move to blue 
; ;

; ; red 
; 		ld 				a, c 						; get back next palette 
; 		srl a 
; 		exx 			; swap regs 

; 		ld 				hl, LUT3BITTO8BIT			; lookup table 
; 		ld 				b, 6
; 		ld 				d,(ix+1)
; 		ld 				e,a
; 		bsrl 			de,b						; 
; 		ld 				a, e 
; 		and 			7 
; 		add 			hl, a 
; 		ld 				a, (hl)

; 		exx 										; back to palette regs 
; 		ld 				(hl), a 					; store 
; 		inc 			hl	

; 9 bit end 
        inc 	ix 				; + 2 to palette location 
        inc 	ix 			
        
        inc 	hl

        pop 	bc 							; repeat loop 
        djnz 	.conver_loop
        ret 

LUT3BITTO8BIT:
        db 0,$24,$49,$6D,$92,$B6,$DB,$FF
LUT2BITTO8BIT:
        db 0,$55,$AA,$FF


pal_rgb_buffer:
        ds 	1024, 0 

pal_nxt_buffer: 
        ds 	512, 0 

palette_buffer:
        db 	0 