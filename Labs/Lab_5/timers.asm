org 0000H
ljmp init

org 0100H
init:
    ; Initialize Timer 0
    mov TMOD, #001H     	; set timer0 mode to mode 01 to use 16-bit count

start:
    ;mov 50H, #0C3H   		; upper byte of 16-bit delay
	;mov 51H, #050H			; lower byte of 16-bit delay
	led:
		mov P1, #0F0H 
		acall delay_1s
		mov P1, #000H
		acall delay_1s
		sjmp led
		
delay_1s:
    mov 50H, #0C3H   		; upper byte of 16-bit delay
	mov 51H, #045H			; lower byte of 16-bit delay
	; if we count 50,000 in delay, calling the delay 40 times will give us a 1s delay 
	mov R0,#028H			; R0 = 40
	loop :
		acall delay
		djnz R0, loop
	ret

delay:
	clr C           		; set C to 0 for subtraction
	mov A, #000H
    subb A, 51H             ; subtract lower byte first
    mov TL0, A              ; Move lower byte of subtraction to TL0
	mov A, #000H
    subb A, 50H             ; subtract upper byte , also subtract carry
	mov TH0, A				; Move upper byte of subtraction to TH0
    setb TR0                ; start timer
    here : jnb TF0,here     ; loop till TF0 flag is set
    clr TF0                 ; clear TF0 for next use
    ret                     ; return to function call
end