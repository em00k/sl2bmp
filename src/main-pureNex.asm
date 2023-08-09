        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        DEVICE ZXSPECTRUMNEXT
        CSPECTMAP       "sl2bmp.map"

        include         "hardware.inc"

        org     $8000
        jp      main 

        include "esxdos.asm"

main:
        
        ; call    getsetdrive 

        ld      hl,filename                     ; get the sl2 filename 
        call    readfile                        ; open the file 
        jp      z, file_open_error              ; quit we couldnt open the file
        ld      (input_handle), a 
        
         
        call    open_sl2

        ; at this point sl2_handle should be set 
         
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
        
         

        ld      hl, outfile                     ; open for writing 
        call    writefile 
        ld      (output_handle), a              ; save handle 

        ld      ix, bmp_header                  ; save header 
        push    ix
        pop     hl 
        ld      bc, 54
        ld      a, (output_handle)
        ESXDOS F_WRITE
        
                 
        call    convert_palette 

        ld      ix, pal_rgb_buffer                  ; save header 
        push    ix
        pop     hl 
        ld      bc, 1024
        ld      a, (output_handle)
        ESXDOS F_WRITE
        
        call    save_sl2
        ld      a, (output_handle)
        ESXDOS  F_CLOSE
         
       ; call    convert_palette 

file_open_error:
        jp      $ 

;------------------------------------------------------------------------------
; Stack reservation
STACK_SIZE      equ     100

stack_bottom:
        defs    STACK_SIZE * 2
stack_top:
        defw    0

filename_len: 
        db      0
filename:
        db      "input.sl2"
        ;ds      255, 0 
outfile: 
        ds      255, 0 
bmp_ext:
        db      "bmp"
input_handle:
        db      0 
output_handle:
        db      0 
;------------------------------------------------------------------------------
; Source Includes 

        include "utils.asm"
        include "layer2.asm"


;------------------------------------------------------------------------------
; Data Includes 

bmp_header: 
        incbin  "bmp_header.bin"

        
;------------------------------------------------------------------------------
; Output configuration
        SAVENEX OPEN "sl2bmp.nex", main, stack_top 
        SAVENEX CORE 2,0,0
        SAVENEX CFG 7,0,0,0
        SAVENEX AUTO 
        SAVENEX CLOSE