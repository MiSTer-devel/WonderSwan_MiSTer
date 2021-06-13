	ORG 0x0000
	CPU 186
	BITS 16

SECTION .data
	%include "WonderSwan.inc"

	MYSEGMENT equ 0xF000
	backgroundMap equ WS_TILE_BANK - MAP_SIZE
	spriteTable equ backgroundMap - SPR_TABLE_SIZE
	
	COLLISION_RADIUS equ 6
	
SECTION .text
	;PADDING 15
	
initialize:
	cli
	cld
	
;-----------------------------------------------------------------------------
; initialize registers and RAM
;-----------------------------------------------------------------------------
	mov ax, MYSEGMENT
	mov ds, ax
	xor ax, ax
	mov es, ax

	; setup stack
	mov bp, ax
	mov ss, ax
	mov sp, WS_STACK

	; clear Ram
	mov di, 0x0100
	mov cx, 0x7E80
	rep stosw

	out IO_SRAM_BANK,al

;-----------------------------------------------------------------------------
; initialize video
;-----------------------------------------------------------------------------
	;in al, IO_VIDEO_MODE
	;or al, VMODE_16C_CHK | VMODE_CLEANINIT
	;out IO_VIDEO_MODE, al

	xor ax, ax
	out IO_BG_X, al
	out IO_BG_Y, al
	out IO_FG_X, al
	out IO_FG_Y, al

	mov al, BG_MAP( backgroundMap )
	out IO_FGBG_MAP, al

	mov al, SPR_TABLE( spriteTable )
	out IO_SPR_TABLE, al

	in al, IO_LCD_CTRL
	or al, LCD_ON
	out IO_LCD_CTRL, al

	xor al, al
	out IO_LCD_ICONS, al

;-----------------------------------------------------------------------------
; initialize variables
;-----------------------------------------------------------------------------
	mov byte [es:scrollCounter], 0
	mov byte [es:workbyte], 0
	mov word [es:workword], 0
	mov byte [es:pageCounter], 0
   
;-----------------------------------------------------------------------------
; register our vblank interrupt handler
;-----------------------------------------------------------------------------
	mov ax, INT_BASE
	out IO_INT_BASE, al

	mov di, INTVEC_VBLANK_START
	add di, ax
	shl di, 2
	mov word [es:di], vblankInterruptHandler
	mov word [es:di + 2], MYSEGMENT

	; clear HBL & Timer
	xor ax, ax
	out IOw_HBLANK_FREQ, ax
	out IO_TIMER_CTRL, al

	; acknowledge all interrupts
	dec al
	out IO_INT_ACK, al

	; enable VBL interrupt
	;mov al, INT_VBLANK_START 
	;out IO_INT_ENABLE, al
   mov al, 0 
	out IO_INT_ENABLE, al

	; we have finished initializing, interrupts can now fire again
	sti

;-----------------------------------------------------------------------------
; copy background tile data (two tiles) to tile bank 1
;-----------------------------------------------------------------------------

	mov si, BackgroundTileData
	mov di, WS_TILE_BANK
	mov cx, BackgroundTileDataEnd - BackgroundTileData
	rep movsb
	
;-----------------------------------------------------------------------------
;  palette
;-----------------------------------------------------------------------------
	
	; setup the 8 colours supported by WonderSwan Mono
	mov al, 00100000b
	out 0x1C, al
	mov al, 01100100b
	out 0x1D, al
	mov al, 10101000b
	out 0x1E, al
	mov al, 11111100b
	out 0x1F, al
	
	; setup palette 0
	mov al, 00001111b ; colours 0 and 1
	out 0x20, al
	mov al, 00000000b ; colours 2 and 3
	out 0x21, al
   
;-----------------------------------------------------------------------------

	; turn on display
	mov al, BG_ON
	out IO_DISPLAY_CTRL, al
   
   mov al, 50
   out IO_FG_WIN_X0, al
   
   mov al, 100
   out IO_FG_WIN_X1, al
   
   mov al, 20
   out IO_FG_WIN_Y0, al
   
   mov al, 60
   out IO_FG_WIN_Y1, al
   
;-----------------------------------------------------------------------------

   jmp tests

;-----------------------------------------------------------------------------
; our vblank interupt handler
; it is called automatically whenever the vblank interrupt occurs, 
; that is, every time the screen is fully drawn
;-----------------------------------------------------------------------------
vblankInterruptHandler:
	iret


waitLine:
   in al, IO_CUR_LINE
   cmp al,bl
   jnz waitLine
   ret
   
;-----------------------------------------------------------------------------

clearscreen:
   mov ax, BG_CHR( 0, 0, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, backgroundMap
	mov cx, MAP_TWIDTH * MAP_THEIGHT
	rep stosw
   ret
   
;-----------------------------------------------------------------------------
   
printstring:
   sal bx, 6
   mov si, dx
stringloop:
   lodsb
   cmp al,0
   jz stringend
   mov byte [es:backgroundMap+bx], al
   add bx,2
   jmp stringloop

stringend:
   ret
   
;-----------------------------------------------------------------------------
   
okfail:
   sal bx, 6
   add bx, 48
   
   cmp cl,dl
   jnz fail
   mov byte [es:backgroundMap+bx], 111
   ret
fail:
   mov byte [es:backgroundMap+bx], 120
   ret
   
;-----------------------------------------------------------------------------
printnumber:
   sal bx, 6
   add bx, cx
   
   mov dl, 10
divrepeat:
   div dl
   mov cl, ah
   add cl, 48
   mov ah, 0
   mov byte [es:backgroundMap+bx], cl
   sub bx, 2
   cmp al, 0
   jnz divrepeat
   ret

;-----------------------------------------------------------------------------
; common test macros
;-----------------------------------------------------------------------------

%macro fill_prefetch 0 
   nop
   nop
   nop
   in al, dx
%endmacro

%macro dotest 2 
   mov cx,1000
align 2
repeat_%2:
   fill_prefetch
   %1
   dec cx
   jnz repeat_%2
%endmacro

%macro dotest2 3 
   mov cx,1000
align 2
repeat_%3:
   fill_prefetch
   %1
   %2
   dec cx
   jnz repeat_%3
%endmacro

%macro SIMPLETEST 2
test_op%2:
   dotest %1, op_%2
   ret
%endmacro

%macro NOTEST 1
test_op%1:
   ret
%endmacro

;-----------------------------------------------------------------------------
; Special test macros
;-----------------------------------------------------------------------------

%macro PUSHTEST 2
test_op%2:
   dotest2 push %1, {add sp, 2}, op%2
   ret
%endmacro

%macro POPTEST 2
test_op%2:
   push %1
   dotest2 pop %1, {sub sp, 2}, op%2
   pop %1
   ret
%endmacro

%macro LOADIMMIDIATE 3
test_op%3:
   dotest {mov %1, %2}, op%3
   ret
%endmacro

%include "tests_special.asm"

%include "tests_op.asm"
   
;-----------------------------------------------------------------------------
; Test procedure
;-----------------------------------------------------------------------------

%macro execute 4  ; line offset, timing, testname, testfunction

   ; print test name
   mov dx, %3   
   mov bx, %1
   sub bx,[es:scrollCounter]
   call printstring
   
   ; print correct value
   mov al, %2
   mov bx, %1
   mov cx, 28
   sub bx,[es:scrollCounter]
   call printnumber
   
   ;set up timer test
   mov al, 0
   out IO_TIMER_CTRL, al
   mov ax, 250
   out IOw_HBLANK_FREQ, ax
   
   ;wait until line zero
   mov bl,0
   call waitLine
   
   ; run test
   mov al, HBLANK_TIMER_ON
   out IO_TIMER_CTRL, al
   call %4
   in ax, IO_HBLANK_CNT1
   mov bl, 250
   sub bl, al
   mov al, bl
   
   ; print ok/fail
   mov bx, %1
   mov cl, %2
   mov dl, al
   sub bx,[es:scrollCounter]
   call okfail 
   
   ; print result
   mov bx, %1
   mov cx, 40
   sub bx,[es:scrollCounter]
   call printnumber
   
%endmacro

tests:
   call clearscreen
   
   mov dx, titleinfo
   mov bx, 0
   sub bx,[es:scrollCounter]
   call printstring
      
%include "testcalls.asm"

	jmp main_loop
   
;-----------------------------------------------------------------------------
main_loop:

   mov bl,144
   call waitLine
   mov bl,143
   call waitLine
   mov bl,142
   call waitLine
   mov bl,141
   call waitLine
   mov bl,140
   call waitLine
   mov bl,139
   call waitLine
   mov bl,138
   call waitLine
   mov bl,137
   call waitLine
   
   ; x buttons
	mov al, KEYPAD_READ_ARROWS_H
	out IO_KEYPAD, al
	nop
	nop
	nop
	nop
	in al, IO_KEYPAD
	
	test al, PAD_RIGHT
	jnz x_right
	
	test al, PAD_LEFT
	jnz x_left

	test al, PAD_UP
	jnz x_up
	
	test al, PAD_DOWN
	jnz x_down
   
   jmp main_loop
   
;-----------------------------------------------------------------------------
   ; x buttons

x_up:
   dec byte [es:scrollCounter]
	jmp tests
x_down:
   inc byte [es:scrollCounter]
	jmp tests
x_left:
   dec byte [es:pageCounter]
	jmp tests
x_right:
   inc byte [es:pageCounter]
	jmp tests

;-----------------------------------------------------------------------------
; constants area
;-----------------------------------------------------------------------------

	align 2

	BackgroundTileData: incbin "ascii.gfx"
	BackgroundTileDataEnd:
	
	author   : db "Written by Robert Peip, 2021"
   testinfo : db "1000 OPs advance CurLine by:"
   
%include "texts.asm"
	
	ROM_HEADER initialize, MYSEGMENT, RH_WS_MONO, RH_ROM_8MBITS, RH_NO_SRAM, RH_HORIZONTAL

SECTION .bss start=0x0100 ; Keep space for Int Vectors
	scrollCounter: resb 1
	workbyte: resb 1
	workword: resb 2
   pageCounter: resb 1
	
