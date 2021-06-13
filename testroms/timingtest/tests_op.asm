;#################################################################
;############ Group 0x0
;#################################################################

test_op00:
   dotest {add byte [workbyte], al}, op00
   ret

test_op01:
   dotest {add word [workword], ax}, op01
   ret
  
test_op02:
   dotest {add byte al, [workbyte]}, op02
   ret
  
test_op03:
   dotest {add word ax, [workword]}, op03
   ret

test_op04:
   dotest {add al, 40}, op04
   ret

test_op05:
   dotest {add ax, 1234}, op05
   ret

test_op06:
   dotest2 push es, {add sp, 2}, op06
   ret

test_op07:
   push es
   dotest2 pop es, {sub sp, 2}, op07
   pop es
   ret

test_op08:
   dotest {or byte [workbyte], al}, op08
   ret

test_op09:
   dotest {or word [workword], ax}, op09
   ret

test_op0A:
   dotest {or byte al, [workbyte]}, op0A
   ret

test_op0B:
   dotest {or word ax, [workword]}, op0B
   ret

test_op0C:
   dotest {or al, 40}, op0C
   ret

test_op0D:
   dotest {or ax, 1234}, op0D
   ret

test_op0E:
   dotest2 push cs, {add sp, 2}, op0E
   ret
  
test_op0F: ; crashes on hardware, likely not supported
   ;push cs
   ;dotest2 pop cs, {sub sp, 2}, op0F
   ;pop cs
   ret  


;#################################################################
;############ Group 0x1
;#################################################################

test_op10:
   dotest {adc byte [workbyte], al}, op10
   ret

test_op11:
   dotest {adc word [workword], ax}, op11
   ret
  
test_op12:
   dotest {adc byte al, [workbyte]}, op12
   ret
  
test_op13:
   dotest {adc word ax, [workword]}, op13
   ret

test_op14:
   dotest {adc al, 40}, op14
   ret

test_op15:
   dotest {adc ax, 1234}, op15
   ret

test_op16:
   dotest2 push ss, {add sp, 2}, op16
   ret

test_op17:
   push ss
   dotest2 pop ss, {sub sp, 2}, op17
   pop ss
   ret

test_op18:
   dotest {sbb byte [workbyte], al}, op18
   ret

test_op19:
   dotest {sbb word [workword], ax}, op19
   ret

test_op1A:
   dotest {sbb byte al, [workbyte]}, op1A
   ret

test_op1B:
   dotest {sbb word ax, [workword]}, op1B
   ret

test_op1C:
   dotest {sbb al, 40}, op1C
   ret

test_op1D:
   dotest {sbb ax, 1234}, op1D
   ret

test_op1E:
   dotest2 push ds, {add sp, 2}, op1E
   ret
  
test_op1F:
   push ds
   dotest2 pop ds, {sub sp, 2}, op1F
   pop ds
   ret  

;#################################################################
;############ Group 0x2
;#################################################################

test_op20:
   dotest {and byte [workbyte], al}, op20
   ret

test_op21:
   dotest {and word [workword], ax}, op21
   ret
  
test_op22:
   dotest {and byte al, [workbyte]}, op22
   ret
  
test_op23:
   dotest {and word ax, [workword]}, op23
   ret

test_op24:
   dotest {and al, 40}, op24
   ret

test_op25:
   dotest {and ax, 1234}, op25
   ret

test_op26:
   dotest {mov ax, [es:workword]}, op26
   ret

test_op27:
   dotest daa, op27
   ret

test_op28:
   dotest {sub byte [workbyte], al}, op28
   ret

test_op29:
   dotest {sub word [workword], ax}, op29
   ret

test_op2A:
   dotest {sub byte al, [workbyte]}, op2A
   ret

test_op2B:
   dotest {sub word ax, [workword]}, op2B
   ret

test_op2C:
   dotest {sub al, 40}, op2C
   ret

test_op2D:
   dotest {sub ax, 1234}, op2D
   ret

test_op2E:
   dotest {mov ax, [cs:workword]}, op2E
   ret
  
test_op2F:
   dotest das, op2F
   ret 


;#################################################################
;############ Group 0x3
;#################################################################

test_op30:
   dotest {xor byte [workbyte], al}, op30
   ret

test_op31:
   dotest {xor word [workword], ax}, op31
   ret
  
test_op32:
   dotest {xor byte al, [workbyte]}, op32
   ret
  
test_op33:
   dotest {xor word ax, [workword]}, op33
   ret

test_op34:
   dotest {xor al, 40}, op34
   ret

test_op35:
   dotest {xor ax, 1234}, op35
   ret

test_op36:
   dotest {mov ax, [ss:workword]}, op36
   ret

test_op37:
   dotest aaa, op37
   ret

test_op38:
   dotest {cmp byte [workbyte], al}, op38
   ret

test_op39:
   dotest {cmp word [workword], ax}, op39
   ret

test_op3A:
   dotest {cmp byte al, [workbyte]}, op3A
   ret

test_op3B:
   dotest {cmp word ax, [workword]}, op3B
   ret

test_op3C:
   dotest {cmp al, 40}, op3C
   ret

test_op3D:
   dotest {cmp ax, 1234}, op3D
   ret

test_op3E:
   dotest {mov ax, [ds:workword]}, op3E
   ret
  
test_op3F:
   dotest aas, op3F
   ret 

;#################################################################
;############ Group 0x4
;#################################################################

SIMPLETEST inc ax, 40
NOTEST 41 ;cx used as countdown
SIMPLETEST inc dx, 42
SIMPLETEST inc bx, 43
NOTEST 44 ;sp modification 
SIMPLETEST inc bp, 45
SIMPLETEST inc si, 46
SIMPLETEST inc di, 47
SIMPLETEST dec ax, 48
NOTEST 49 ;cx used as countdown
SIMPLETEST dec dx, 4A
SIMPLETEST dec bx, 4B
NOTEST 4C ;sp modification  
SIMPLETEST dec bp, 4D
SIMPLETEST dec si, 4E
SIMPLETEST dec di, 4F

   
;#################################################################
;############ Group 0x5
;#################################################################

PUSHTEST ax, 50
PUSHTEST cx, 51
PUSHTEST dx, 52
PUSHTEST bx, 53
PUSHTEST sp, 54
PUSHTEST bp, 55
PUSHTEST si, 56
PUSHTEST di, 57
POPTEST  ax, 58
NOTEST       59 ; cx used as countdown
POPTEST  dx, 5A
POPTEST  bx, 5B
NOTEST       5C ; crashes on WS, why?
POPTEST  bp, 5D
POPTEST  si, 5E
POPTEST  di, 5F

;#################################################################
;############ Group 0x6
;#################################################################

test_op60:
   dotest2 db 0x60, {add sp, 16}, op60
   ret

test_op61:
   mov cx,1000
align 2
repeat_op61:
   fill_prefetch
   push cx
   db 0x61
   sub sp, 16
   pop cx 
   dec cx
   jnz repeat_op61
   ret
   
PUSHTEST 1234, 68

test_op69:
   dotest dd 0x04D20069, op69 ; mul ax <= 1234,mem
   ret

PUSHTEST 42, 6A

test_op6B:
   dotest2 db 0x6B, dw 0x2A00, op6B ; mul ax <= 42,mem
   ret
   
;#################################################################
;############ Group 0x8
;#################################################################

test_op80:
   dotest {add byte [workword], 42}, op80
   ret
   
test_op81:
   dotest {add word [workword], 1234}, op81
   ret
   
test_op82:
   dotest2 db 0x82, dd 0xD6000206, op82 ; add byte [workword], -42
   ret
   
test_op83:
   dotest {add word [workword], -42}, op83
   ret

test_op84:
   dotest {test byte al,[workword]}, op84
   ret
   
test_op85:
   dotest {test word ax,[workword]}, op85
   ret
   
test_op86:
   dotest {xchg byte al,[workword]}, op86
   ret
   
test_op87:
   dotest {xchg word ax,[workword]}, op87
   ret
   
test_op88:
   dotest {mov byte [workword],bl}, op88
   ret
   
test_op89:
   dotest {mov word [workword],bx}, op89
   ret
   
test_op8A:
   dotest {mov byte bl,[workword]}, op8A
   ret
   
test_op8B:
   dotest {mov word bx,[workword]}, op8B
   ret
   
test_op8C:
   dotest {mov ax, ss}, op8C
   ret
   
test_op8D:
   dotest {lea ax, [workword]}, op8D
   ret

test_op8E:
   push es
   dotest {mov es, [workword]}, op8E
   pop es
   ret

test_op8F:
   push ax
   dotest2 pop word [workword], {sub sp, 2}, op8F
   pop ax
   ret

;#################################################################
;############ Group 0x9
;#################################################################

SIMPLETEST nop, 90

test_op91:
   dotest2 {xchg ax, cx}, {mov cx, ax}, op91
   ret
   
test_op92:
   dotest {xchg ax, dx}, op92
   ret
   
test_op93:
   dotest {xchg ax, bx}, op93
   ret
   
test_op94:
   dotest2 {xchg ax, sp}, {mov sp, ax}, op94
   ret
   
test_op95:
   dotest2 {xchg ax, bp}, {mov bp, ax}, op95
   ret
   
test_op96:
   dotest2 {xchg ax, si}, {mov si, ax}, op96
   ret
   
test_op97:
   dotest2 {xchg ax, di}, {mov di, ax}, op97
   ret
  
SIMPLETEST db 0x98, 98 ; sign extend byte
SIMPLETEST db 0x99, 99 ; sign extend word 
  
test_op9C:
   dotest2 {pushf}, {add sp, 2}, op9C
   ret
   
test_op9D:
   pushf
   dotest2 {popf}, {sub sp, 2}, op9D
   popf
   ret
  
SIMPLETEST db 0x9E, 9E ; acc to flags
SIMPLETEST db 0x9F, 9F ; flags to acc

;#################################################################
;############ Group 0xA
;#################################################################

test_opA0:
   dotest {mov al, [workword]}, opA0
   ret
   
test_opA1:
   dotest {mov ax, [workword]}, opA1
   ret

test_opA2:
   dotest {mov byte [workword], al}, opA2
   ret
   
test_opA3:
   dotest {mov word [workword], ax}, opA3
   ret
    
test_opA4:
   push si
   push di
   push es
   mov ax,0xF000 
   mov es,ax
   dotest movsb, opA4
   pop es
   pop di
   pop si
   ret
  
test_opA5:
   push si
   push di
   push es
   mov ax,0xF000 
   mov es,ax
   dotest movsw, opA5
   pop es
   pop di
   pop si
   ret
   
test_opA6:
   push si
   push di
   dotest cmpsb, opA6
   pop di
   pop si
   ret
   
test_opA7:
   push si
   push di
   dotest cmpsw, opA7
   pop di
   pop si
   ret
   
test_opA8:
   dotest {test al, 42}, opA8
   ret
   
test_opA9:
   dotest {test ax, 1234}, opA9
   ret

test_opAA:
   push di
   push es
   mov ax,0xF000 
   mov es,ax
   dotest stosb, opAA
   pop es
   pop di
   ret
   
test_opAB:
   push di
   push es
   mov ax,0xF000 
   mov es,ax
   dotest stosw, opAB
   pop es
   pop di
   ret
   
test_opAC:
   push si
   dotest lodsb, opAC
   pop si
   ret
   
test_opAD:
   push si
   dotest lodsw, opAD
   pop si
   ret
   
test_opAE:
   push di
   dotest scasb, opAE
   pop di
   ret
   
test_opAF:
   push di
   dotest scasw, opAF
   pop di
   ret

;#################################################################
;############ Group 0xB
;#################################################################

LOADIMMIDIATE al,   42, B0
NOTEST B1 ;cx used as countdown
LOADIMMIDIATE dl,   42, B2
LOADIMMIDIATE bl,   42, B3
LOADIMMIDIATE ah,   42, B4
NOTEST B5 ;cx used as countdown
LOADIMMIDIATE dh,   42, B6
LOADIMMIDIATE bh,   42, B7
LOADIMMIDIATE ax, 1234, B8
NOTEST B9 ;cx used as countdown
LOADIMMIDIATE dx, 1234, BA
LOADIMMIDIATE bx, 1234, BB

test_opBC:
   mov bx,sp
   dotest {mov sp, 1234}, opBC
   mov sp,bx
   ret
   
test_opBD:
   push bp
   dotest {mov bp, 1234}, opBD
   pop bp
   ret
   
test_opBE:
   push si
   dotest {mov si, 1234}, opBE
   pop si
   ret
   
test_opBF:
   push di
   dotest {mov di, 1234}, opBF
   pop di
   ret

;#################################################################
;############ Group 0xC
;#################################################################

test_opC0:
   dotest {ror byte [workword], 2}, opC0
   ret
   
test_opC1:
   dotest {ror word [workword], 2}, opC1
   ret   
   
test_opC4:
   push es
   dotest {les ax, [workword]}, opC4
   pop es
   ret   
   
test_opC5:
   push ds
   dotest {lds ax, [workword]}, opC5
   pop ds
   ret  
   
test_opC6:
   dotest {mov byte [workword], 42}, opC6
   ret 
   
test_opC7:
   dotest {mov word [workword], 1234}, opC7
   ret 
   
   
;#################################################################
;############ Group 0xD
;#################################################################   
   
test_opD0:
   dotest {ror byte [workword], 1}, opD0
   ret 

test_opD1:
   dotest {ror word [workword], 1}, opD1
   ret 

test_opD2:
   dotest {ror byte [workword], cl}, opD2
   ret 

test_opD3:
   dotest {ror word [workword], cl}, opD3
   ret    
   
SIMPLETEST aam, D4
SIMPLETEST aad, D5
   
SIMPLETEST db 0xD6, D6 ; xlat mirror
SIMPLETEST xlatb, D7
   
   
;#################################################################
;############ Group 0xE
;#################################################################      
   
test_opE4:
   dotest {in al, 0}, opE4
   ret    
   
test_opE5:
   dotest {in ax, 0}, opE5
   ret    
   
test_opE6:
   dotest {out 44, al}, opE6
   ret    

test_opE7:
   dotest {out 44, ax}, opE7
   ret      
   
test_opEC:
   mov dx, 0
   dotest {in al, dx}, opEC
   ret    
   
test_opED:
   mov dx, 0
   dotest {in ax, dx}, opED
   ret    
   
test_opEE:
   mov dx, 44
   dotest {out dx, al}, opEE
   ret    

test_opEF:
   mov dx, 44
   dotest {out dx, ax}, opEF
   ret         
   
;#################################################################
;############ Group 0xF
;#################################################################       

SIMPLETEST clc, F8   
SIMPLETEST stc, F9   
SIMPLETEST cli, FA   
NOTEST FB ; cannot activate interrupts
SIMPLETEST cld, FC   
NOTEST FD ; cannot activate direction
   
;#################################################################
;############ Group mem imm 3  
;#################################################################      
   
test_I30:
   dotest {test byte [workword], 42}, opI30
   ret 

test_I32:
   dotest {not byte [workword]}, opI32
   ret    
   
test_I33:
   dotest {neg byte [workword]}, opI33
   ret  
   
test_I34:
   dotest {mul byte [workword]}, opI34
   ret 
   
test_I35:
   dotest {imul byte [workword]}, opI35
   ret  
   
test_I36:
   mov word [es:workword], 1 
   dotest {div byte [es:workword]}, opI36
   ret  
   
test_I37:
   mov word [es:workword], 1 
   dotest {idiv byte [es:workword]}, opI37
   ret
   
test_I38:
   dotest {test word [workword], 42}, opI38
   ret 

test_I3A:
   dotest {not word [workword]}, opI3A
   ret    
   
test_I3B:
   dotest {neg word [workword]}, opI3B
   ret  
   
test_I3C:
   dotest {mul word [workword]}, opI3C
   ret 
   
test_I3D:
   dotest {imul word [workword]}, opI3D
   ret  
 

test_I3E:
   mov word [es:workword], 1 
   ; dotest {div word [es:workword]}, opI3E ; crashes on ws 
   ret  
   
test_I3F:
   mov word [es:workword], 1 
   ;dotest {idiv word [es:workword]}, opI3F ; crashes on ws 
   ret 
 
;#################################################################
;############ Group mem imm 4
;#################################################################     
   
test_I40:
   dotest {inc byte [workword]}, opI40
   ret    
   
test_I41:
   dotest {dec byte [workword]}, opI41
   ret 
   
test_I48:
   dotest {inc word [workword]}, opI48
   ret    
   
test_I49:
   dotest {dec word [workword]}, opI49
   ret 
   
test_I4E:
   dotest2 {push word [workword]}, {add sp, 2}, opI46
   ret     
   
   
