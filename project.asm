.include "m2560def.inc"

.def temp1 = r16
.def temp2 = r17
.def temp3 = r22
.def temp4 = r23
;;;;;;keypad register and parameter;;;;;;;;
.def row = r18 ; current row number
.def col = r19 ; current column number
.def rmask = r20 ; mask for current row during scan
.def cmask = r21 ; mask for current column during scan
.equ PORTFDIR = 0xF0 ; PF7-4: output, PF3-0, input
.equ INITCOLMASK = 0xEF ; scan from the leftmost column,
.equ INITROWMASK = 0x01 ; scan from the top row
.equ ROWMASK =0x0F ; for obtaining input from Port F
;;;;;;LCD parameter;;;;;;;;;;;;;;;;;;;;;;;
.equ LCD_CTRL_PORT = PORTA
.equ LCD_CTRL_DDR = DDRA
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4
.equ LCD_DATA_PORT = PORTK
.equ LCD_DATA_DDR = DDRK
.equ LCD_DATA_PIN = PINK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.macro STORE
.if @0 > 63
sts @0, @1
.else
out @0, @1
.endif
.endmacro

.macro LOAD
.if @1 > 63
lds @0, @1
.else
in @0, @1
.endif
.endmacro
;;;;;;;;;;;;macro;;;;;;;;;;;;;;;;
.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro
.macro do_lcd_n
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro
.macro lcd_set
	sbi LCD_CTRL_PORT, @0
.endmacro
.macro lcd_clr
	cbi LCD_CTRL_PORT, @0
.endmacro
.macro pressDelay  ; press delay for keypad 
	ldi r28, low(5000)
	ldi r29, high(5000)
	ldi r27, 170
loop: 
	adiw r29:r28, 1
	cpi r29, high(5000)
	breq done 
	rjmp loop 
done:
	clr r28
	clr r29
	dec r27
	brne loop	
.endmacro

.equ loop_count=124 ; press delay for one second
.macro oneSecondDelay
	ldi r28,low(loop_count)
	ldi r29,high(loop_count)
	clr r27
	clr r26
 loop:cp r26,r28
 	  cpc r27,r29
	  brsh done
	  call sleep_20ms
	  adiw r27:r26,1
	  nop 
	  rjmp loop
 done:
 	  nop
.endmacro
;;;;;;;;;;transfer value between data memory and register;;;;;;
.macro transfer_to_data ; transfer value of helicopter to dseg
	ldi XL, low(@1)
	ldi XH, high(@1)
	ldi temp1, @0
	st X,temp1
.endmacro
.macro transfer_to_register ; transfer value of helicopter to register
	ldi XL, low(@0)
	ldi XH, high(@0)
	ld @1, X
.endmacro
.macro move_to_data ; move value of helicopter to dseg
	ldi XL, low(@1)
	ldi XH, high(@1)
	mov temp1, @0
	st X,temp1
.endmacro
.macro transfer_between_data
	transfer_to_register @0, temp1
	move_to_data temp1, @1
.endmacro

;;;;;;;;;;;;;;;;;;;;data memory and program memory;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.dseg
.org 0x200
button_flag: .byte 1
currentposX: .byte 1
currentposY: .byte 1
currentposZ: .byte 1
finalposX: .byte 1
finalposY: .byte 1
finalposZ: .byte 1
search_flag: .byte 1
number_counter: .byte 1
speed: .byte 1
aposX: .byte 1
aposY: .byte 1
aposZ: .byte 1
bposX: .byte 1
bposY: .byte 1
bposZ: .byte 1
cposX: .byte 1
cposY: .byte 1
cposZ: .byte 1
input_count: .byte 1
acc_flag: .byte 1
find_flag: .byte 1
.cseg
.org 0
	jmp RESET
.org INT0addr
	jmp EXT_INT0
.org INT1addr
	jmp EXT_INT1


map:
line1: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line2: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line3: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line4: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line5: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line6: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line7: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line8: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line9: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line10: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line11: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line12: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line13: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line14: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line15: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line16: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line17: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line18: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line19: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line20: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line21: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line22: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line23: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line24: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line25: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line26: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line27: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line28: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line29: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line30: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line31: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line32: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line33: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line34: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line35: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line36: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line37: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line38: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line39: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line40: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line41: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line42: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line43: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line44: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line45: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line46: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line47: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line48: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line49: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line50: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line51: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line52: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line53: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line54: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line55: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line56: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line57: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line58: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line59: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17
line60: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line61: .db 10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,10,11,12,10,10,10,10,10,10,10,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line62: .db 10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,10,11,21,21,12,15,15,15,17,20,10,10,10,10,10,16,16,16,16,16,33,14,52,31
line63: .db 20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,20,22,24,44,64,48,49,47,42,40,40,40,42,43,44,45,36,36,36,36,10,10,10,10
line64: .db 30,22,23,44,65,66,66,56,56,60,66,66,56,56,60,56,55,55,57,55,31,33,39,37,46,76,66,65,85,80,80,66,66,56,56,60,56,55,55,57,32,38,41,37,46,76,66,65,65,60,60,66,66,56,56,60,56,55,55,57,44,23,46,17


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXT_INT0:
	call flyback
	ret
EXT_INT1:
	
	call loadmap
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



RESET:
    clr temp3
    ;;;;initial helicopter;;;;;
	transfer_to_data 0,button_flag
	transfer_to_data 0,currentposX
	transfer_to_data 0,currentposY
	transfer_to_data 0,currentposZ
	transfer_to_data 0,finalposX
	transfer_to_data 0,finalposY
	transfer_to_data 0,finalposZ
	transfer_to_data 0,number_counter
	transfer_to_data 0,speed
	transfer_to_data 0,aposX
	transfer_to_data 0,aposY
	transfer_to_data 0,aposZ
	transfer_to_data 0,bposX
	transfer_to_data 0,bposY
	transfer_to_data 0,bposZ
	transfer_to_data 0,cposX
	transfer_to_data 0,cposY
	transfer_to_data 0,cposZ
	transfer_to_data 0,input_count
	transfer_to_data 1,acc_flag
	transfer_to_data 0,find_flag
	;;;;;;;;;;;;;motor;;;;;;;;;;;;;;
	ldi r16,0b00001000
	sts DDRL,r16
	
	ldi r16,0xff
	sts OCR5AL,r16
	clr r16
	sts OCR5AH,r16
	
	ldi r16,(1<<CS50)|(1<<CS51)
	sts TCCR5B, r16
	ldi r16,(1<<WGM50)|(1<<COM5A1)|(1<<COM5A0)
	sts TCCR5A,r16
	
	;;;;;;;;;;;;;led;;;;;;;;;;;;;
	ser temp1
	out DDRC, temp1
	;;;;;;;;;;;;keyboard;;;;;;;;;;;;;;;
    clr r16 ; keypad 
    ldi r16, PORTFDIR ; PF7:4/PF3:0, out/in
	out DDRF, r16
	;;;;;;;;;;;;stack;;;;;;;;;;;;
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	;;;;;;;;;;;;;;lcd;;;;;;;;;;;;;;;
	ser r16
	STORE LCD_DATA_DDR, r16
	STORE LCD_CTRL_DDR, r16
	clr r16
	STORE LCD_DATA_PORT, r16
	STORE LCD_CTRL_PORT, r16

	do_lcd_command 0b00111000 ; 2x5x10
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x10
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x10
	do_lcd_command 0b00111000 ; 2x5x10
	do_lcd_command 0b00001000 ; display off
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	do_lcd_data 'G'
	do_lcd_command 0b11000000
	do_lcd_data 'X'
	do_lcd_data ':'
	;enable external interrupt
	;ldi r16,(2<<ISC00)|(2<<ISC10)
	;sts EICRA,r16
	;in r16,EIMSK
	ldi r16, (1<<INT0|1<<INT1)
	;ori r16,(1<<INT0)|(1<<INT1)
	out EIMSK,r16
	sei
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
	call led_bar
	;call motor_speed
	ldi cmask, INITCOLMASK ; initial column mask
	clr col ; initial column
colloop:
	cpi col,4
	breq main; if all keys are scanned, repeat;
	out PORTF, cmask; otherwise, scan a column
	;out PORTF, cmask
	ldi temp1, 0xFF
delay: 
	pressDelay
	;dec temp1
	;brne delay
	in temp1, PINF ; read PORTF
	andi temp1, ROWMASK ; get the keypad output value
	cpi temp1, 0xF ; check if any row is low
	breq nextcol 	; if yes, find which row is low
	ldi rmask, INITROWMASK ; initialize for row check
	clr row ; 
rowloop:
	cpi row, 4
	breq nextcol ; the row scan is over.
	mov temp2, temp1
	and temp2, rmask ; check un-masked bit
	breq convert ; if bit is clear, the key is pressed
	inc row ; else move to the next row
	lsl rmask
	jmp rowloop
nextcol: ; if row scan is over
	lsl cmask
	inc col ; increase column value
	jmp colloop ; go to the next column
convert:
	cpi col,3
	breq carry
	cpi row, 3					; if row is 3 we have a symbol or 0
	breq symbols
	mov temp1, row				; otherwise we have a number in 1-9
	lsl temp1
	add temp1, row				; temp1 = row * 3
	add temp1, col				; add the column address to get the value
	subi temp1,-1
	mov temp4, temp1
	mov temp3, temp1
	call display_number
	;do_lcd_data 'X'
	;jmp main
	jmp convert_end
symbols:
	cpi col, 0					; check if we have a star
	breq star
	cpi col, 1						; or if we have zero
	breq zero
	cpi col, 2
	jmp fin_pos
zero:
	ldi temp4, 0
	mov temp3, temp4
	call display_number							; or if we have zero
	breq convert_end
convert_end:
	transfer_to_register number_counter, temp1
	inc temp1
	move_to_data temp1, number_counter
	cpi temp1, 3
	brge carry
	transfer_to_register currentposY, temp2
	ldi temp3, 10
	mul temp3, temp2
	add r0, temp4
	mov temp3, r0
	cpi temp3, 65
	brge carry
	move_to_data r0, currentposY
	transfer_to_register input_count, temp1
	inc temp1
	move_to_data temp1, input_count
	jmp main

carry:
	;transfer_to_register number_counter, temp1
	ldi temp1, 0
	move_to_data temp1, number_counter
	call led_overflow
	;do_lcd_data 'O'
	jmp main
star:
	transfer_to_register input_count, temp3
	cpi temp3,1
	brge change_pos
	move_to_data temp3, acc_flag
change_pos:
	clr temp1
	move_to_data temp1, input_count
	do_lcd_data 'Y'
	do_lcd_data ':'
	transfer_to_register currentposY, temp3
	move_to_data temp3, currentposX
	;do_lcd_command 0b11000000
	;call display_number
	clr temp3
	move_to_data temp3, currentposY
	ldi temp1, 0
	move_to_data temp1, number_counter
	;do_lcd_command 0b00000001
	;do_lcd_command 0b00010100
	;do_lcd_command 0b00010100
	;do_lcd_command 0b00010100
	jmp main
fin_pos:
	transfer_to_register input_count, temp3
	cpi temp3,1
	brge final_xy
	clr temp3
	move_to_data temp3, acc_flag
final_xy:
	transfer_to_register input_count, temp3
	cpi temp3, 1
	brlo noinput
	transfer_to_register currentposX, temp3
	move_to_data temp3, finalposX
	do_lcd_command 0b11000000
	do_lcd_data '('
	call display_number
	do_lcd_data ','
	transfer_to_register currentposY, temp3
	move_to_data temp3, finalposY
	call display_number
	do_lcd_data ')'
	do_lcd_data ' '
	do_lcd_data ' '
	jmp main
noinput:
	ldi temp3, 65
	move_to_data temp3, finalposX
	move_to_data temp3, finalposY
	do_lcd_command 0b11000000
	do_lcd_data 'n'
	do_lcd_data 'o'
	do_lcd_data ' '
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'p'
	do_lcd_data 'u'
	do_lcd_data 't'
	jmp main


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_command:
	STORE LCD_DATA_PORT, r16
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

lcd_wait:
	push r16
	clr r16
	STORE LCD_DATA_DDR, r16
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RW
lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	LOAD r16, LCD_DATA_PIN
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	STORE LCD_DATA_DDR, r16
	pop r16
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret
sleep_20ms:
	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	ret
sleep_100ms:
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	ret
sleep_500ms:
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	ret
;;;;;wait half second;;;;;;;
sleep_halfSecond:
	ldi r31,high(500)
	ldi r30,low(500)
delayloop_halfSecond:
	call sleep_1ms
	sbiw r31:r30,1
	brne delayloop_halfSecond
	clr r31
	clr r30
	ret

;;;;;;;;;;;;;;;;;;;display number;;;;;;;;;;;;;;;;;;;;;;;
display_number:
	clr temp2
	cpi temp3,10
    brge two_bit_number
	jmp one_bit_number
two_bit_number:
	subi temp3,10
	inc temp2
	cpi temp3,10
	brge two_bit_number
	subi temp2, -'0'
	do_lcd_n temp2
	clr temp2
	jmp one_bit_number
one_bit_number:
	subi temp3,-'0'
	do_lcd_n temp3
	clr temp2
	ret

;;;;;;;;;;;;;display led bar;;;;;;;;;;
led_bar:
	ldi temp1, 0xFF
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0xFF
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0xFF
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0
	out DDRC,temp1
	ret

led_overflow:
	ldi temp1, 1
	out DDRC,temp1
	ldi temp1, 0xEF
	out portC,temp1
	call sleep_500ms
	ldi temp1, 0
	out portC,temp1
	ret

;;;;;;;;;;;;show all pos;;;;;;;;;;;;;;;

showpos:
	clr temp3
	do_lcd_command 0b11000000
	rcall sleep_100ms
	transfer_to_register cposX, temp3
	call display_number
	do_lcd_data ','
	transfer_to_register cposY, temp3
	call display_number
	do_lcd_data ','
	transfer_to_register cposZ, temp3
	call display_number
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	ret

;;;;;;;;;;;;;search;;;;;;;;;;;;;
loadmap:
	clr row
	clr col
	ldi temp1, low(map<<1)
	ldi temp2, high(map<<1)
	mov zl, temp1
	mov zh, temp2
	jmp readmap
readmap:
	;do_lcd_data 'A'
	cpi row, 64
	breq fread
	cpi col, 64
	breq ncol
	lpm temp3, z+
	;call display_number
	transfer_between_data bposX, aposX
	transfer_between_data bposY, aposY
	transfer_between_data bposZ, aposZ
	move_to_data row, bposX
	move_to_data col, bposY
	move_to_data temp3, bposZ	
	call fly_a_b
	transfer_to_register find_flag, temp1
	cpi temp1, 1
	breq fread
	;ret
	inc col
	jmp readmap
ncol:
	;do_lcd_data 'B'
	;ret
	clr col
	inc row
	jmp readmap
fread:
	transfer_to_register find_flag, temp1
	cpi temp1, 1
	brne notfoundacc
	do_lcd_command 0b00000001
	do_lcd_data 'f'
	do_lcd_data 'o'
	do_lcd_data 'u'
	do_lcd_data 'n'
	do_lcd_data 'd'
	call showpos
	call flyback
	ret	
notfoundacc:
	do_lcd_command 0b00000001
	do_lcd_data 'n'
	do_lcd_data 'o'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'f'
	do_lcd_data 'o'
	do_lcd_data 'u'
	do_lcd_data 'n'
	do_lcd_data 'd'
	call flyback
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flyback:
	ldi temp4, 4
	move_to_data temp4, speed
	call motor_speed
	call showpos
	transfer_to_register cposZ, temp1
	cpi temp1, 64
	breq flybackX
	inc temp1
	move_to_data temp1, cposZ
	jmp flyback
flybackX:
	call showpos
	transfer_to_register cposX, temp1
	cpi temp1, 0
	breq flybackY
	dec temp1
	move_to_data temp1, cposX
	jmp flybackX
flybackY:
	call showpos
	transfer_to_register cposY, temp1
	cpi temp1, 0
	breq flybackdown
	dec temp1
	move_to_data temp1, cposY
	jmp flybackY
flybackdown:
	call showpos
	transfer_to_register cposZ, temp1
	cpi temp1, 0
	breq flyground
	dec temp1
	move_to_data temp1, cposZ
	jmp flybackdown
flyground:
	ldi temp4, 0
	move_to_data temp4, speed
	call motor_speed
	do_lcd_command 0b00000001
	do_lcd_data 'R'
	transfer_to_register find_flag, temp1
	cpi temp1, 1
	breq showresult
	do_lcd_command 0b11000000
	do_lcd_data 'n'
	do_lcd_data 'o'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'f'
	do_lcd_data 'o'
	do_lcd_data 'u'
	do_lcd_data 'n'
	do_lcd_data 'd'
	ret
showresult:
	do_lcd_command 0b11000000
	transfer_between_data bposX,cposX
	transfer_between_data bposY,cposY
	transfer_between_data bposZ,cposZ
	call showpos
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;

fly_a_b:
	do_lcd_command 0b00000001
	do_lcd_data 'F'
	ldi temp4, 4
	move_to_data temp4, speed
	call motor_speed
	call showpos
	transfer_between_data aposX, cposX
	transfer_between_data aposY, cposY
	transfer_between_data aposZ, cposZ
	;do_lcd_data 'J'
	;call showpos
	;ret
	;do_lcd_data 'B'
	transfer_to_register cposX, rmask
	transfer_to_register bposX, cmask
	;mov temp3, rmask
	;call display_number
	;mov temp3, cmask
	;call display_number
	;ret
	cp rmask, cmask
	brne flynext
	jmp flyu
flyu:
	call showpos
	;do_lcd_data 'C'
	transfer_to_register cposZ, rmask
	transfer_to_register bposZ, cmask
	cp rmask, cmask
	brge flyYp	
	inc rmask
	move_to_data rmask, cposZ
	jmp flyu
flyYp:
	call showpos
	;do_lcd_data 'D'
	transfer_to_register cposY, rmask
	transfer_to_register bposY, cmask
	;mov temp3, temp1
	;call display_number
	;mov temp3, temp2
	;call display_number
	;ret
	cp rmask, cmask
	brge flyend1
	inc rmask
	move_to_data rmask, cposY
	jmp flyYp
flyend1:
	call showpos
	transfer_to_register cposZ, rmask
	transfer_to_register bposZ, cmask
	cp rmask, cmask
	breq flyend2
	dec rmask
	move_to_data rmask, cposZ
	jmp flyend1
flyend2:
	jmp flyend
	ret
flynext:
	;do_lcd_data 'E'
	transfer_to_register cposZ, rmask
	cpi rmask, 64
	brge flynextX
	call showpos
	inc rmask
	move_to_data rmask, cposZ
	jmp flynext
flynextX:
	;do_lcd_data 'F'
	transfer_to_register cposX, rmask
	inc rmask
	move_to_data rmask, cposX
	call showpos
	jmp flynextY
flynextY:
	;do_lcd_data 'G'
	transfer_to_register cposY, rmask
	cpi rmask, 0
	breq flynextd
	call showpos
	dec rmask
	move_to_data rmask, cposY
	jmp flynextY
flynextd:
	;do_lcd_data 'H'
	transfer_to_register cposZ, rmask
	transfer_to_register bposZ, cmask
	cp rmask, cmask
	breq flyend
	call showpos
	dec rmask
	move_to_data rmask, cposZ
	jmp flynextd
flyend:
	do_lcd_command 0b00000001
	do_lcd_data 'H'
	ldi temp4, 1
	move_to_data temp4, speed
	call motor_speed
	call showpos
	oneSecondDelay
	transfer_to_register finalposX, temp1
	transfer_to_register cposX, temp2
	cp temp1, temp2
	breq checknext
	ret
checknext:
	transfer_to_register finalposY, temp1
	transfer_to_register cposY, temp2
	cp temp1, temp2
	breq findtheacc
	ret
findtheacc:
	ldi temp1, 1
	move_to_data temp1, find_flag
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
motor_speed:
	transfer_to_register speed,temp3
	cpi temp3,0 ;5 speed level
	breq speed0
	cpi temp3,1
	breq speed1
	cpi temp3,2
	breq speed2
	cpi temp3,3
	breq speed3
	cpi temp3,4
	breq speed4
	ret
speed0:
	ldi temp3, 0Xff
	sts OCR5AL,temp3
	clr temp3
	sts OCR5AH,r31
	ret
speed1:	
	ldi temp3, 0Xaf
	sts OCR5AL,temp3
	clr temp3
	sts OCR5AH,r31
	ret
speed2:	
	ldi temp3, 0X5f
	sts OCR5AL,temp3
	clr temp3
	sts OCR5AH,r31
	ret
speed3:	
	ldi temp3, 0X2f
	sts OCR5AL,temp3
	clr temp3
	sts OCR5AH,r31
	ret
speed4:	
	ldi temp3, 0X00
	sts OCR5AL,temp3
	clr temp3
	sts OCR5AH,r31
	ret

