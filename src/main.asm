        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        DEVICE ZXSPECTRUMNEXT
        CSPECTMAP       "sl2bmp.map"

        include         "hardware.inc"

        org     $2000
main:
        jp      begin 
        db      "SL2BMP"
        db      "0.6-em00k"

        include "esxdos.asm"

begin: 
      
        di 
        ld      a,h
        or      l								; check if a command line is empty 
        jr      nz,commandlineOK						; get hl if = 0 then no command line given, else jump to commandlineOK
        ld      hl,emptyline							; show help text 
        call    print_rst16							; print message 
        jp      end_out			

commandlineOK: 
        ld      (commandline), hl                                  

        nextreg $69,1<<7

        call    getsetdrive

        ld      hl,(commandline)                                                     ; get back command line        ; call    getsetdrive 

        ld      de,filename                                                   ; point de to our text buffer 
        ld      b,0                                                             ; flatten b 
         
scanline:

        ld      a,(hl)								; load char into a 
        cp      ":"     : jr    z,finishscan					; was it : ? then we're done 
        or      a       : jr    z,finishscan					; was it 0 ? 
        cp      13      : jr    z,finishscan					; or was it return 13 ?
       
        ld      (de),a  : inc   hl : inc de				        ; none of the above so copy to de and inc addresses 

continueloop:
        djnz    scanline							; keep going until b = 0 
        jr      finishscan                                                      ; jump to finishedscan 

finishscan:
        xor     a : ld    (de),a						; ensure end of filename has a zero

        ld      hl, filename     
        call    readfile                        ; open the file 
         
        jp      c, file_open_error              ; quit we couldnt open the file
        ld      (input_handle), a 

        call    open_sl2
        ld      a, (input_handle)
        ESXDOS  F_CLOSE

        ; we have the sl2 loaded into L2 pages 

        ld      hl, filename                    ; count the file name length 
        call    count_str_length                ; 

        ld      (filename_len), a               ; save the filelength 

        sub     3                               ; take off extension 
        ld      b, 0 
        ld      hl, filename
        ld      de, outfile
        ld      c, a 
        ldir                                    ; 
        ld      hl, bmp_ext
        ld      bc, 3 
        ldir                                    ; outfile = filename now filename.bmp 
        xor     a 
        ld      (de), a                         ; ensure zero terminated 
         

        ld      hl, outfile                     ; open for writing 
        call    writefile 
        ld      (output_handle), a              ; save handle 

        ld      ix, bmp_header                  ; save header 
        push    ix
        pop     hl 
        ld      bc, 54
        ld      a, (output_handle)
        ESXDOS  F_WRITE
                         
        call    convert_palette                  ; convert L2 palette to RGB

        ld      ix, pal_rgb_buffer               ; save header 
        push    ix
        pop     hl 
        ld      bc, 1024                        ; RGBA * 256
        ld      a, (output_handle)
        ESXDOS F_WRITE
        
        call    save_sl2
        ld      a, (output_handle)
        ESXDOS  F_CLOSE
         

        jp      end_out

file_open_error:
        ld      hl, error_opening
        call    print_rst16

end_out:
        ld      iy, $5c3a 
        xor     a
        ei 
        ret   

emptyline               db      "SL2BMP .6 - em00k 090823",13,13
                        ;        -------------------------------
                        db      "Converts SL2 to a BMP.",13
                        db      "Uses first L2 palette.",13,13

                        db      "Usage : ",13,13 
                        db      "   .SL2BMP myimage.sl2",13
                        db      13,0 
textbuffer              ds      256,0
error_opening           db      "Error opening file",0 
commandline             dw      0000

filename_len: 
        db      0
filename:
        ;db      "input.sl2"
        ds      255, 0 
outfile: 
        ds      255, 0 
bmp_ext:
        db      "bmp", 0 
input_handle:
        db      0 , 0 
output_handle:
        db      0 , 0 

;------------------------------------------------------------------------------
; Source Includes 

        include "utils.asm"
        include "layer2.asm"


;------------------------------------------------------------------------------
; Data Includes 

bmp_header: 
        incbin  "bmp_header.bin"

endofdot:


;------------------------------------------------------------------------------
; Stack reservation
STACK_SIZE      equ     100

stack_bottom:
        defs    STACK_SIZE * 2
stack_top:
        defw    0,0


;------------------------------------------------------------------------------
; Output configuration
        ; SAVENEX OPEN "sl2bmp.nex", main, stack_top 
        ; SAVENEX CORE 2,0,0
        ; SAVENEX CFG 7,0,0,0
        ; SAVENEX AUTO 
        ; SAVENEX CLOSE

        savebin "sl2bmp",main,endofdot-main
        ; savebin "s",main,endofdot-main