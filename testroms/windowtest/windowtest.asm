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
	
	; write sprite tile data to the beginning of bank 1
	mov si, SpriteTileData
	mov di, WS_TILE_BANK
	mov cx, SpriteTileDataEnd - SpriteTileData
	rep movsb
	
;-----------------------------------------------------------------------------
; configure hardware sprites, by telling WS to use our sprite tiles and 
; palette
;-----------------------------------------------------------------------------

%macro SETSPRITES 2
	; tell WonderSwan which sprites we'd like displayed
	mov al, 0 ; first sprite to enable (inclusive)
	out IO_SPR_START, al
	mov al, 128 ; last+1 sprite to enable (exclusive)
	out IO_SPR_STOP, al
	

   ; read address of sprite table area
	in al, IO_SPR_TABLE
	mov ah, 0
	shl ax, 9 ; ax now points to the beginning of sprite table area
	mov di, ax ; offset our sprite number from the beginning 

   mov bx, 8
   mov dx, 0x4040
for%2bx:
   mov dh, 0x10
   mov cx, 16
   for%2cx:
      mov word [es:di], %1
      add di, 2
      mov word [es:di], dx
      add di, 2
      
      add dh, 8
      
      dec cx
      jnz for%2cx
   add dl, 8
   dec bx
   jnz for%2bx
%endmacro

   SETSPRITES 0x2053, spriteinit
   
	; turn on display
	mov al, BG_ON | FG_ON | SPR_ON
	out IO_DISPLAY_CTRL, al
   
   mov al, 50
   out IO_FG_WIN_X0, al
   
   mov al, 100
   out IO_FG_WIN_X1, al
   
   mov al, 20
   out IO_FG_WIN_Y0, al
   
   mov al, 60
   out IO_FG_WIN_Y1, al
   
   mov al, 80
   out IO_SPR_WIN_X0, al
   
   mov al, 130
   out IO_SPR_WIN_X1, al
   
   mov al, 80
   out IO_SPR_WIN_Y0, al
   
   mov al, 100
   out IO_SPR_WIN_Y1, al
   
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


	call clearlines
   
   PRINTTEXT 0, 0, textbg2
   PRINTPOS 0, 30, IO_FG_WIN_X0
   PRINTPOS 0, 38, IO_FG_WIN_Y0
   PRINTPOS 0, 46, IO_FG_WIN_X1
   PRINTPOS 0, 54, IO_FG_WIN_Y1

   PRINTTEXT 1, 0, textspr
   PRINTPOS 1, 30, IO_SPR_WIN_X0
   PRINTPOS 1, 38, IO_SPR_WIN_Y0
   PRINTPOS 1, 46, IO_SPR_WIN_X1
   PRINTPOS 1, 54, IO_SPR_WIN_Y1
   
   mov al, [es:mode]
   cmp al, 0
   jz printmode0
   cmp al, 1
   jz printmode1
   cmp al, 2
   jz printmode2
   cmp al, 3
   jz printmode3
   cmp al, 4
   jz printmode4
   
printmode0:
   PRINTTEXT 0, 16, textoff
   PRINTTEXT 1, 16, textoff
	jmp endprintmode
   
printmode1:
   PRINTTEXT 0, 16, texton
   PRINTTEXT 0, 22, textin
   PRINTTEXT 1, 16, textoff
	jmp endprintmode
   
printmode2:
   PRINTTEXT 0, 16, texton
   PRINTTEXT 0, 20, textout
   PRINTTEXT 1, 16, textoff
	jmp endprintmode
   
printmode3:
   PRINTTEXT 0, 16, textoff
   PRINTTEXT 1, 16, texton
   PRINTTEXT 1, 22, textin
	jmp endprintmode
   
printmode4:
   PRINTTEXT 0, 16, textoff
   PRINTTEXT 1, 16, texton
   PRINTTEXT 1, 22, textout
	jmp endprintmode   
   
endprintmode:
   
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
	mov cx, 0x1000
input_delay:
	dec cx
	jnz input_delay
	
	; no input, restart main game loop
	jmp main_loop


;-----------------------------------------------------------------------------
; x buttons
;-----------------------------------------------------------------------------

x_up:
   cmp byte [es:mode], 2
   jg x_up_spr
   in al, IO_FG_WIN_Y0
	dec al
	out IO_FG_WIN_Y0, al
	jmp main_loop_wait
   
x_up_spr:  
   in al, IO_SPR_WIN_Y0
	dec al
	out IO_SPR_WIN_Y0, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
x_down:
   cmp byte [es:mode], 2
   jg x_down_spr
   in al, IO_FG_WIN_Y0
	inc al
	out IO_FG_WIN_Y0, al
	jmp main_loop_wait
   
x_down_spr:
   in al, IO_SPR_WIN_Y0
	inc al
	out IO_SPR_WIN_Y0, al
	jmp main_loop_wait
  
;-----------------------------------------------------------------------------
   
x_left:
   cmp byte [es:mode], 2
   jg x_left_spr
   in al, IO_FG_WIN_X0
	dec al
	out IO_FG_WIN_X0, al
	jmp main_loop_wait
   
x_left_spr:
   in al, IO_SPR_WIN_X0
	dec al
	out IO_SPR_WIN_X0, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
x_right:
   cmp byte [es:mode], 2
   jg x_right_spr
   in al, IO_FG_WIN_X0
	inc al
	out IO_FG_WIN_X0, al
	jmp main_loop_wait
   
x_right_spr:
   in al, IO_SPR_WIN_X0
	inc al
	out IO_SPR_WIN_X0, al
	jmp main_loop_wait
 
;----------------------------------------------------------------------------- 
; y buttons
;-----------------------------------------------------------------------------

y_up:
   cmp byte [es:mode], 2
   jg y_up_spr
   in al, IO_FG_WIN_Y1
	dec al
	out IO_FG_WIN_Y1, al
	jmp main_loop_wait
   
y_up_spr:
   in al, IO_SPR_WIN_Y1
	dec al
	out IO_SPR_WIN_Y1, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_down:
   cmp byte [es:mode], 2
   jg y_down_spr
   in al, IO_FG_WIN_Y1
	inc al
	out IO_FG_WIN_Y1, al
	jmp main_loop_wait
   
y_down_spr:
   in al, IO_SPR_WIN_Y1
	inc al
	out IO_SPR_WIN_Y1, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_left:
   cmp byte [es:mode], 2
   jg y_left_spr
   in al, IO_FG_WIN_X1
	dec al
	out IO_FG_WIN_X1, al
	jmp main_loop_wait
   
y_left_spr:
   in al, IO_SPR_WIN_X1
	dec al
	out IO_SPR_WIN_X1, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
   
y_right:
   cmp byte [es:mode], 2
   jg y_right_spr
   in al, IO_FG_WIN_X1
	inc al
	out IO_FG_WIN_X1, al
	jmp main_loop_wait
   
y_right_spr:
   in al, IO_SPR_WIN_X1
	inc al
	out IO_SPR_WIN_X1, al
	jmp main_loop_wait
   
;-----------------------------------------------------------------------------
; other buttons
;-----------------------------------------------------------------------------

pressS:
   cmp byte [es:lastbutton], 0
   jnz main_loop_wait
   mov byte [es:lastbutton], 1
   
   mov al, [es:mode]
   cmp al, 4
   jz modeoverflow
   inc al
   jmp modeNoOverflow
modeoverflow:
   mov al, 0
modeNoOverflow:  
   mov [es:mode], al
   cmp al, 0
   jz mode0
   cmp al, 1
   jz mode1
   cmp al, 2
   jz mode2
   cmp al, 3
   jz mode3
   cmp al, 4
   jz mode4
   
mode0:
   mov al, BG_ON | FG_ON | SPR_ON
   out IO_DISPLAY_CTRL, al
	jmp main_loop_wait
   
mode1:
   mov al, BG_ON | FG_ON | SPR_ON | FG_WIN_ON
   out IO_DISPLAY_CTRL, al
	jmp main_loop_wait
   
mode2:
   mov al, BG_ON | FG_ON | SPR_ON | FG_WIN_ON | FG_WIN_OUT
   out IO_DISPLAY_CTRL, al
	jmp main_loop_wait
   
mode3:
   mov al, BG_ON | FG_ON | SPR_ON | SPR_WIN_ON
   out IO_DISPLAY_CTRL, al
   SETSPRITES 0x2053, spriteIN
	jmp main_loop_wait
   
mode4:
   mov al, BG_ON | FG_ON | SPR_ON | SPR_WIN_ON
   out IO_DISPLAY_CTRL, al
   SETSPRITES 0x3053, spriteOUT
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
   textbg2 : db "BG2 Win:", 0
   textspr : db "SPR Win:", 0
   textin  : db "IN", 0
   textout : db "OUT", 0   
   texton  : db "ON", 0
   textoff : db "OFF", 0
	
	ROM_HEADER initialize, MYSEGMENT, RH_WS_MONO, RH_ROM_8MBITS, RH_NO_SRAM, RH_HORIZONTAL

SECTION .bss start=0x0100 ; Keep space for Int Vectors
	frameCounter: resb 1
	globalFrameCounter: resb 1
	numFramesToSkipBGScroll: resb 1
	
	mode: resb 1
	lastbutton: resb 1
	
	enemySpawnPosition: resb 1 ; this is used to decide the Y coordinate
							   ; of the enemy car when it spawns
							   ; by adding to it based on player input
							   ; to "randomize" it a bit :)
