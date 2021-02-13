org 0000
ljmp main

org 100H
	main:
	mov P1, #003H							; Initialization for taking inputs
	start:
		mov C, P1.0
		anl C, P1.1
		jc both_set								; Both are set so move to corresponding loop
		jb P1.0, pin_4							; Only toggle pin 4
		jb P1.1, pin_6							; Only toggle pin 6
		sjmp start								; end


pin_4:
	clr P1.6							; incase P1.6 is 1 at transition, clear it 
	setb P1.4
	lcall delay_1s						; wait 1s

	clr P1.4
	mov R0,#3
	repeat3:
		lcall delay_1s
		djnz R0, repeat3				; wait 3*1s
	ljmp start


pin_6:
	clr P1.4							; incase P1.4 is 1 at transition, clear it
	setb P1.6
	lcall delay_1s
	lcall delay_1s
	clr P1.6
	lcall delay_1s
	lcall delay_1s
	ljmp start							; recheck input						


both_set:
	setb P1.4
	setb P1.6

	lcall delay_1s						; wait 1s
	clr P1.4
	lcall delay_1s						; wait 1s
	clr P1.6
	lcall delay_1s
	lcall delay_1s						; wait 2s
	ljmp start							; recheck input


delay_1s:
	mov R1,#8							; 8 * 125 ms = 1s
	loop4:
		mov R2,#250
		loop3:
			mov R3,#249					; initially both were taken 250, later fine-tuned by trial and error
			mov R4,#249
			loop1:djnz R3, loop1		; 249*2 cycles
			loop2:djnz R4, loop2		; 249*2 cycles (2 cycles added thru djnz)
			; 1000 cycles per loop of R2
			djnz R2,loop3 				; 250*(996) cycles ~ 125 ms
		djnz R1,loop4					; 8 * (250*(996)+2) cycles ~ 1s
	ret
end