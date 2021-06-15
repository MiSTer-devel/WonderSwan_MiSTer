;-----------------------------------------------------------------------------
;
;  Swan Driving BW
;         by Sebastian Mihai, 2015
;         http://sebastianmihai.com
;
;  [This is a back-port of Swan Driving, to run on a Wonderswan Mono]
;
;  For more information on the hardware specs, port descriptions, sprite
;  format, etc., see the hardware.txt file in the wonderdev root directory.
;  It's a great document to help you understand how certain things are done.
;
;  I didn't aim for performance and code size when I wrote this. I opted to
;  make it more readable, which means that sometimes extra I have added extra
;  instructions, to more clearly show what I'm doing.
;
;  UP/DOWN    - move car
;  LEFT/RIGHT - low/high gear
;
;  Assemble with: 
;                   nasm -f bin -o swandrivingBW.ws swandrivingBW.asm
;
;-----------------------------------------------------------------------------

	ORG 0x0000
	CPU 186
	BITS 16

SECTION .data
	%include "WonderSwan.inc"

	MYSEGMENT equ 0xF000
	backgroundMap equ WS_TILE_BANK - MAP_SIZE
	forgroundMap equ WS_TILE_BANK + MAP_SIZE
	spriteTable equ backgroundMap - SPR_TABLE_SIZE
	
	COLLISION_RADIUS equ 6
	
SECTION .text
	;PADDING 15
	
initialize:
	cli
	cld

;-----------------------------------------------------------------------------
; if it's not the Mono version of the console, lock the CPU
;-----------------------------------------------------------------------------
	in al, IO_HARDWARE_TYPE
	test al, WS_COLOR
lock_cpu:
	jnz lock_cpu ; expect it to not have the "Color" bit set
	
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

	mov al, BG_MAP( backgroundMap ) | FG_MAP( forgroundMap )
	out IO_FGBG_MAP, al

	mov al, SPR_TABLE( spriteTable )
	out IO_SPR_TABLE, al

	in al, IO_LCD_CTRL
	or al, LCD_ON
	out IO_LCD_CTRL, al

	xor al, al
	out IO_LCD_ICONS, al

;-----------------------------------------------------------------------------
; initialize game variables
;-----------------------------------------------------------------------------
	mov byte [es:frameCounter], 0
	mov byte [es:globalFrameCounter], 0
	mov byte [es:numFramesToSkipBGScroll], 4
	
	mov byte [es:mode], 0
	mov byte [es:lastbutton], 0
	mov byte [es:posx0], 80
	mov byte [es:posy0], 80
	mov byte [es:posx1], 100
	mov byte [es:posy1], 100
	
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
; copy  tile data
; into WS's tile and palette areas
;-----------------------------------------------------------------------------
	; copy background tile data (two tiles) to tile bank 1
	; immediately following sprite tile data
	mov si, BackgroundTileData
	mov di, WS_TILE_BANK + SpriteTileDataEnd - SpriteTileData
	mov cx, BackgroundTileDataEnd - BackgroundTileData
	rep movsb
	
;-----------------------------------------------------------------------------
; copy background (road and railing) and foreground (rain) tile palettes
; into WS's palette areas
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

	; setup palette 1
	mov al, 00010000b ; colours 0 and 1
	out 0x22, al
	mov al, 01110010b ; colours 2 and 3
	out 0x23, al
	
;-----------------------------------------------------------------------------
; make background map point to our tiles, essentially "painting" the
; background layer with out tiles, coloured as per our palettes
;-----------------------------------------------------------------------------	

	; write tile 0 (first background tile) to each of the background map tiles
	mov ax, BG_CHR( 0, 0, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, backgroundMap
	mov cx, MAP_TWIDTH * MAP_THEIGHT
	rep stosw
	
   
   ; write B to each of the forground map tiles
	mov ax, BG_CHR(66, 1, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, forgroundMap
	mov cx, MAP_TWIDTH * MAP_THEIGHT
	rep stosw
   
   ; write tile 0 to each of the forground map tiles in rows 0 and 1
	mov ax, BG_CHR(1, 4, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, forgroundMap
	mov cx, MAP_TWIDTH * 2
	rep stosw
;-----------------------------------------------------------------------------
; load sprite tile data and palette
;-----------------------------------------------------------------------------	
	
	; setup palette 8
	mov al, 00010111b ; colours 0 and 1
	out 0x30, al
	mov al, 00010010b ; colours 2 and 3
	out 0x31, al
   
   ; setup palette 9
	mov al, 00010000b ; colours 0 and 1
	out 0x32, al
	mov al, 01100010b ; colours 2 and 3
	out 0x33, al
	
	; write sprite tile data to the beginning of bank 1
	mov si, SpriteTileData
	mov di, WS_TILE_BANK
	mov cx, SpriteTileDataEnd - SpriteTileData
	rep movsb
	
;-----------------------------------------------------------------------------
; configure hardware sprites, by telling WS to use our sprite tiles and 
; palette
;-----------------------------------------------------------------------------

%macro SETSPRITES 0
	; tell WonderSwan which sprites we'd like displayed
	mov al, 0 ; first sprite to enable (inclusive)
	out IO_SPR_START, al
	mov al, 2 ; last+1 sprite to enable (exclusive)
	out IO_SPR_STOP, al

   ; read address of sprite table area
	in al, IO_SPR_TABLE
	mov ah, 0
	shl ax, 9 ; ax now points to the beginning of sprite table area
	mov di, ax ; offset our sprite number from the beginning 

   mov word [es:di], 0x0031
   mov al, [es:posy0]
   mov byte [es:di+2], al
   mov al, [es:posx0]
   mov byte [es:di+3], al
   add di, 4  
   
   mov word [es:di], 0x2232
   mov al, [es:posy1]
   mov byte [es:di+2], al
   mov al, [es:posx1]
   mov byte [es:di+3], al
%endmacro
   
	; turn on display
	mov al, BG_ON | FG_ON | SPR_ON | FG_WIN_ON
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
; done initializing... we can now start the main game loop
;-----------------------------------------------------------------------------

	; start main game loop
	jmp main_loop

;-----------------------------------------------------------------------------
; our vblank interupt handler
; it is called automatically whenever the vblank interrupt occurs, 
; that is, every time the screen is fully drawn
;-----------------------------------------------------------------------------
vblankInterruptHandler:
	iret

;-----------------------------------------------------------------------------

clearscreen:
   mov ax, BG_CHR( 0, 0, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, backgroundMap
	mov cx, MAP_TWIDTH * MAP_THEIGHT
	rep stosw
   ret
   
;-----------------------------------------------------------------------------

clearlines:
   mov ax, BG_CHR( 0, 0, 0, 0, 0 ) ; BG_CHR(tile,pal,bank,hflip,vflip)
	mov di, backgroundMap
	mov cx, MAP_TWIDTH * 2
	rep stosw
   ret

;-----------------------------------------------------------------------------
   
printstring:
   sal bx, 6
   add bx, cx
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
; BEGIN main area
;-----------------------------------------------------------------------------

%macro PRINTTEXT 3
   mov dx, %3  
   mov bx, %1
   mov cx, %2
   call printstring
%endmacro

%macro PRINTPOS 3
   in al, %3
   mov bx, %1
   mov cx, %2
   call printnumber
%endmacro

main_loop:

   SETSPRITES

   PRINTTEXT 0, 0, textspr1
   PRINTTEXT 1, 0, textspr2
   
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
   
   ; y buttons
	mov al, KEYPAD_READ_ARROWS_V
	out IO_KEYPAD, al
	nop
	nop
	nop
	nop
	in al, IO_KEYPAD
	
	test al, PAD_RIGHT
	jnz y_right
	
	test al, PAD_LEFT
	jnz y_left

	test al, PAD_UP
	jnz y_up
	
	test al, PAD_DOWN
	jnz y_down
   
   ; other buttons
	mov al, KEYPAD_READ_BUTTONS
	out IO_KEYPAD, al
	nop
	nop
	nop
	nop
	in al, IO_KEYPAD
	
	test al, PAD_START
	jnz pressS
	
	test al, PAD_A
	jnz pressA

	test al, PAD_B
	jnz pressB
	
   
   mov byte [es:lastbutton], 0		
   		
   
main_loop_wait:
   
;artificial delay
	mov cx, 0x3000
input_delay:
	dec cx
	jnz input_delay
	
	; no input, restart main game loop
	jmp main_loop


;-----------------------------------------------------------------------------
; x buttons
;-----------------------------------------------------------------------------

x_up:
   dec byte [es:posy0]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
x_down:
   inc byte [es:posy0]
	jmp main_loop_wait
  
;-----------------------------------------------------------------------------
   
x_left:
   dec byte [es:posx0]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
x_right:
   inc byte [es:posx0]
	jmp main_loop_wait
 
;----------------------------------------------------------------------------- 
; y buttons
;-----------------------------------------------------------------------------

y_up:
   dec byte [es:posy1]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_down:
   inc byte [es:posy1]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_left:
   dec byte [es:posx1]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_right:
   inc byte [es:posx1]
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
; other buttons
;-----------------------------------------------------------------------------

pressS:
	jmp main_loop_wait   

;-----------------------------------------------------------------------------
   
pressA:
   ;mov al, BG_ON | FG_ON | SPR_ON | FG_WIN_ON
	;out IO_DISPLAY_CTRL, al
	jmp main_loop_wait
   
pressB:
	;mov al, BG_ON | FG_ON | SPR_ON | FG_WIN_ON | FG_WIN_OUT
	;out IO_DISPLAY_CTRL, al
	jmp main_loop_wait
	
;-----------------------------------------------------------------------------
; constants area
;-----------------------------------------------------------------------------

	align 2

	BackgroundTileData: incbin "ascii.gfx"
	BackgroundTileDataEnd:
	
	SpriteTileData: incbin "ascii.gfx"
	SpriteTileDataEnd:
	
	author: db "Written by Robert Peip, 2021"
   textspr1 : db "Spr1 below BG2, above Spr2", 0
   textspr2 : db "Spr2 above BG2, below Spr1", 0
	
	ROM_HEADER initialize, MYSEGMENT, RH_WS_MONO, RH_ROM_8MBITS, RH_NO_SRAM, RH_HORIZONTAL

SECTION .bss start=0x0100 ; Keep space for Int Vectors
	frameCounter: resb 1
	globalFrameCounter: resb 1
	numFramesToSkipBGScroll: resb 1
	
	mode: resb 1
   lastbutton: resb 1
	posx0: resb 1
	posy0: resb 1
	posx1: resb 1
	posy1: resb 1

