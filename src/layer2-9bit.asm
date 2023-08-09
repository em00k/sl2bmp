
convert_palette: 
		 
		; first get the l2 palette and store in pal_nxt_buffer 

		nextreg PALETTE_CONTROL_NR_43, %00010000	; ensure L2 palette is selected 
		nextreg $40,0 								; move to index 0 
		ld 		hl, pal_nxt_buffer                  ; empty next format buffer

		ld 		b, 0                                ; 256 loops
		ld 		c, 0                                ; c is palette index 

.col_loop
		ld 		a, $41                              ; read reg $41, 8bit colour value
		call    getRegister
		ld 		(hl), a                             ; store in buffer 
		inc 	hl
		ld 		a, $44                              ; get blue bit 
		call 	getRegister
		ld 		(hl), a                             ; store in buffer
		inc 	hl 
		inc 	c                                   ; increase palette index 
		ld		a, c 
		nextreg $40,a
		djnz 	.col_loop                           ; loop until b = 0 

		ld 		b, 0 ; 256 colours 
		ld 		ix, pal_nxt_buffer                  ; filled next format buffer 
		ld 		hl, pal_rgb_buffer                  ; empty BGRA * 256 buffer (1024bytes)
		 
.conver_loop:
		 
		push 	bc                                  ; save loop counter 
		; now convert 333 to 24bit RGB

		ld 		a, (ix+0)                           ; get 8 bit colour 
		ld 		c, a 	                            ; save a
	
; blue 

		sla     a                                   ; xxxxxxB2B1 << 1 = B2B1x 
		ld 	    b, (ix+1)		                    ; xxxxxxxB0
		or      b                                   ; merge to get xxxxxBBB
		and     7 
		exx 	                                    ; swap to spare regs 
		ld 		hl, LUT3BITTO8BIT                   ; hl point to lookup table 
		
		add 	hl, a                               ; get the RGB value from lookup 
		ld 		a, (hl)                             

		exx 	                                    ; swap back to palette regs 
		ld 		(hl), a 					        ; store valu in BGRA buffer 
		inc 	hl							        ; move to green
		
; green 
		ld 		a, c 						        ; get back next palette 
		exx 									    ; shadow regs
		ld 		hl, LUT3BITTO8BIT			        ; 
		srl 	a 			                        ; xxxGGGxx
		srl 	a 							        ; >> 2 = xxxxxGGG
		and 	7 
		add 	hl, a 
		ld 		a, (hl)						        ; get value 

		exx 								        ; swap regs 
		ld 		(hl), a 					        ; store green 
		inc 	hl							        ; move to red

; red 
		ld 		a, c 						        ; get back next palette 
		exx 	                                    ; swap regs 

		ld 		hl, LUT3BITTO8BIT			        ; lookup table 
		swapnib                                     ; RRRxxxxx > xxxxRRRx
		srl     a                                   ; xxxxxRRR
		and     7 
		add 	hl, a 
		ld 		a, (hl)

		exx 								        ; back to palette regs 
		ld 		(hl), a 					        ; store 
		inc 	hl	

		inc 	ix 				                    ; + 2 to move IX to next palette value pair
		inc 	ix 			
		
		inc 	hl                                  ; move hl to skip alpha byte in BGRA

		pop 	bc 							        ; repeat loop 
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