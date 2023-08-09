	
M_GETSETDRV 	equ $89
F_OPEN 			equ $9a
F_CLOSE 		equ $9b
F_READ 			equ $9d
F_WRITE 		equ $9e
F_SEEK 			equ $9f
F_GET_DIR 		equ $a8
F_SET_DIR 		equ $a9

FA_READ 		equ $01
FA_APPEND 		equ $06
FA_OVERWRITE 	equ $0C

	macro ESXDOS command
		rst 	8
		db 		command
	endm

getsetdrive:
		xor 	a                           ; A=0, get the default drive
		ESXDOS M_GETSETDRV
		ld 		(DefaultDrive),a
		ret

DefaultDrive:
		db   '*'

readfile: 

		ld 		a, (DefaultDrive) 				; use current drive
		ld 		b, FA_READ 						; set mode
		ESXDOS 	F_OPEN
		ret 	
	

writefile: 

		ld 		a, (DefaultDrive) 				; use current drive
		ld 		b, FA_OVERWRITE 			; set mode
		
		ESXDOS 	F_OPEN
		ret 	
	


handle: db 0

open_sl2:	
		ld 		e,18				; def is 18
		ld 		a, e 
		nextreg	$56, a		; set MMU6

.loadfile:

		push 	de 
		ld 		hl, $c000
		ld 		bc, 8192			; load in 8kb chunks 
		ld 		a, (input_handle)
		ESXDOS 	F_READ
		; bc will = bytes read, does it = 8192?
		pop 	de 
		inc 	e
		ld 		a, e  
		nextreg $56, a 
		ld 		a, $20 
		cp 		b
		ret		nz
		jr 		.loadfile
			
save_sl2:	

		ld 		hl, $c000
		ld 		bc, 8192			; load in 8kb chunks 
		ld 		a,18				; start bank 20 
		nextreg	$56, a		

.save_file:

		push 	af 					; save curr modbank 
		ld 		hl, $c000
		ld 		bc, 8192			; load in 8kb chunks 
		ld 		a,(output_handle)
		ESXDOS 	F_WRITE
		pop 	af					; get back bank 
		inc 	a
		nextreg $56, a 
		cp 		24				
		ret		z
		jr 		.save_file
		