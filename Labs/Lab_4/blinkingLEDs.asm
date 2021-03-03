org 000H
ljmp blinkingLEDs

org 100H
blinkingLEDs:
	mov TMOD, #001H
    mov P1, #0FFH            ; 0FFH = 11111111 F1.7-1.4 set, F1.3-1.0 for input

    ;setb P1.7
    ;setb P1.6
    ;setb P1.5
    ;setb P1.4

    acall delay_1s
    acall delay_1s
    acall delay_1s
    acall delay_1s
    acall delay_1s

    mov A, #00FH            ; A = 00001111
    anl A, P1               ; A = 0000<lower_nibble>
	mov R0, A

    jz blinkingLEDs                ; if A = 0, return

    iterate:
        acall blink
        djnz R0, iterate
    
    sjmp blinkingLEDs


blink:
    mov P1, #000H           ; reset P1.7-P1.4 and stop input from P1.3-P1.0
    acall delay_1s
    mov P1, #0F0H
    acall delay_1s
    ret


delay_1s:
	mov R4,#200
		loop:
		mov TH0, #0D8H			
		mov TL0, #0FAH
		setb TR0
			here: jnb TF0,here
		clr TR0
		clr TF0
		djnz R4,loop
	ret

end