sw1      equ P1.0   ; Switch    
led      equ P1.4   ; LED 
LCD_data equ P2     ; LCD Data port
LCD_rs   equ P0.0   ; LCD Register Select
LCD_rw   equ P0.1   ; LCD Read/Write
LCD_en   equ P0.2   ; LCD Enable

org 0000H
ljmp init

org 000BH               ; Timer 0 Interrupt
inc R0                  ; inc overflow count by 1
reti                    

org 0100H
init:
    ; Enable interrupts
    setb EA                 ; enable interrupts
    setb ET0                ; enable T0 interrupt
	mov P1, #001H			; enable input only from sw1 and turn off all leds

    ; Initialize timers
    mov TMOD, #011H         ; both T0 and T1 used in mode 1, T0 for reaction time, T1 for delay

    ; Initialize LCD 
    acall lcd_init
    acall delay 
    acall delay             

main:
    ; Display start message
    mov a,#83h              ; Put cursor on first row, 3 column
	acall lcd_command	    ; send command to LCD
	acall delay

	mov   dptr,#my_string1  ; Load DPTR with string1 Addr
	acall lcd_sendstring	; call text strings sending routine
	acall delay

	mov a,#0C2h		        ; Put cursor on second row, 2 column
	acall lcd_command
	acall delay

	mov   dptr,#my_string2  ; Load DPTR with string2 Addr
	acall lcd_sendstring    ; call text strings sending routine
    acall delay_1s
    acall delay_1s          ; wait 2s

    ; Init count
    mov R0, #000H           ; init overflow count
    mov TH0, #000H          ; init timer count
    mov TL0, #000H          

    ; turn on LED 
    setb led

    ; start counting
    setb TR0

    ; wait till SW1 is turned ON
    here : jnb sw1, here
    clr TR0                 ; stop count
    clr led                 ; turn off led

    ; Display reaction time
    mov   LCD_data,#01H  ;Clear LCD
    clr   LCD_rs         ;Selected command register
    clr   LCD_rw         ;We are writing in instruction register
    setb  LCD_en         ;Enable H->L
	acall delay
    clr   LCD_en
	acall delay
	acall delay

    mov a,#80h              ; Put cursor on first row, 1 column
	acall lcd_command	    ; send command to LCD
	acall delay

	mov   dptr,#my_string3  ; Load DPTR with string3 Addr
	acall lcd_sendstring	; call text strings sending routine
	acall delay

	mov a,#0C0h		        ; Put cursor on second row, 0 column
	acall lcd_command
	acall delay

	mov   dptr,#my_string4  ; Load DPTR with string4 Addr
	acall lcd_sendstring    ; call text strings sending routine
    acall delay

    ; Print overflow count
    mov a, #0F0H
    anl a, R0               ; get top nibble of overflow count
    swap a                  ; swap to move to lower nibble
    acall hex_to_ascii      ; convert to ascii
    acall lcd_senddata      ; print 
    acall delay


    mov a, #00FH
    anl a, R0
    acall hex_to_ascii
    acall lcd_senddata
    acall delay

    mov a, #014H            ; move cursor by 1 to the right
    acall lcd_command
    acall delay

    ; Print TH0
    mov a, #0F0H
    anl a, TH0               ; get top nibble of overflow count
    swap a                  ; swap to move to lower nibble
    acall hex_to_ascii      ; convert to ascii
    acall lcd_senddata      ; print 
    acall delay

    mov a, #00FH
    anl a, TH0
    acall hex_to_ascii
    acall lcd_senddata
    acall delay

    ; Print TL0
    mov a, #0F0H
    anl a, TL0               ; get lower nibble of overflow count
    swap a                  ; swap to move to lower nibble
    acall hex_to_ascii      ; convert to ascii
    acall lcd_senddata      ; print 
    acall delay

    mov a, #00FH
    anl a, TL0
    acall hex_to_ascii
    acall lcd_senddata
    acall delay

    acall delay_1s
    acall delay_1s
    acall delay_1s
    acall delay_1s
    acall delay_1s          ; wait for 5s

    mov   LCD_data,#01H  ;Clear LCD
    clr   LCD_rs         ;Selected command register
    clr   LCD_rw         ;We are writing in instruction register
    setb  LCD_en         ;Enable H->L
    acall delay
    clr   LCD_en 

    ; return
    loop_reset: jb sw1, loop_reset      ; wait till SW1 moved back to 0
    ljmp main

delay_1s:
    mov R1, #40
    iter:
        mov TH1, #03CH
        mov TL1, #0B0H
        setb TR1
        loop3 : jnb TF1, loop3
        clr TF1
        djnz R1, iter
    ret

; convert 1 digit hex value in A to ascii for printing to LCD
hex_to_ascii: 
    cjne a,#00AH,next
    next: jc below_9
    add A, #037H        ; add 37H because a > 9, hence it's a character
    ret
    below_9:
    add A, #030H        ; add 30H because a <= 9, hence it's a number
    ret


;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret

;------------- ROM text strings---------------------------------------------------------------org 300h
my_string1:
         DB   "Toggle SW1", 00H
my_string2:
		 DB   "if LED glows", 00H
my_string3:
         DB   "Reaction Time", 00H
my_string4:
		 DB   "Count is ", 00H
end
