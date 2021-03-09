LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

org 0000H
ljmp start					; initialize lcd first org(300H)
 
org 0100H
init:
    ; Initialize Timer 0 for 0.2/8 s 
    mov TMOD, #001H     	; set timer0 mode to mode 01 to use 16-bit count
	mov P1, #0F7H           ; Initialize P1 to take input
    
main:
    mov A, #007H			; Mask
    anl A, P1
    mov R4, A               ; Get input value
	
	;On-time
	mov A, #009H
    subb A, R4              ; A = 9-input
    mov r7,A                ; save for duty cycle calc
    mov B, #008H            ; B = 8
    mul AB                  ; iterations = 8 * (9-input)
    mov R5, A               
	
	;Off-time
    mov A, #050H			; A = 80 (total iterations which were required for 2s period)
    subb A, R5              ; A = remaining iterations for 2s period
    mov R6, A

;Display on LCD
	;Duty Cycle
    mov a,#80h		                ; Put cursor on first row,0 column
    lcall lcd_command	            ; send command to LCD
    mov   dptr,#my_string1          ; Load DPTR with string1 Addr
    lcall lcd_sendstring	        ; call text strings sending routine

    mov A,R7                        ; A = ten's digit of duty cycle
    add A,#030H                     ; ascii code for the duty cycle
    lcall lcd_senddata
    mov A, #030H                    ; one's digit of duty cycle is always 0
    lcall lcd_senddata
    
	;Pulse Width
    mov a,#0C0h		                ; Put cursor on second row,0 column
    lcall lcd_command
    mov   dptr,#my_string2
    lcall lcd_sendstring
	
    mov A,R7
    mov B,#002H                     ; Multiply (9-inp) with 2 to get 10*pw
    mul AB
    mov B,#00AH
    div AB                          ; Divide that by 10 to get first digit in A and second digit in B
    add A, #030H
    lcall lcd_senddata              ; Write each digit one by one
    mov A,B
    add A,#030H
    lcall lcd_senddata
    mov A, #030H                    ; last 2 digits of pw always 0
    lcall lcd_senddata
    lcall lcd_senddata

    ; Start pwm 
    acall pwm						; Run 1 period of pwm signal
    sjmp main

pwm: 
; Time period = 80 * 0.2/8 = 2s => Frequency = 0.5 Hz
    ; On-cycle
	setb P1.4
	setb P1.5
	setb P1.6
	setb P1.7
    loop_1:
        acall delay_x
        djnz R5, loop_1

	;Off-cycle
	clr P1.4
	clr P1.5
	clr P1.6
	clr P1.7
    loop_2:
        acall delay_x
        djnz R6, loop_2
    ret

delay_x:
; creates delay of 0.2/8 s
	mov TH0, #03CH
    mov TL0, #0BCH
    setb TR0                ; start timer
    here : jnb TF0,here     ; loop till TF0 flag is set
    clr TF0                 ; clear TF0 for next use
    ret                     ; return to function call

;---------------------------------LCD------------------------------------------------------------------
org 300h
start:
      mov P2,#00h
      mov P2,#00h
	  ;initial delay for lcd power up
	  acall delay
	  acall delay

	  acall lcd_init      ; initialise LCD
      ljmp init           ; move to pwm

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
    
;------------- ROM text strings---------------------------------------------------------------
my_string1:
        DB   "Duty Cycle: ", 00H
my_string2:
		DB   "Pulse Width:", 00H
end
