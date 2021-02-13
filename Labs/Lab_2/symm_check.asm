; Inputs 
mov 60H, #004H
mov 61H, #087H
mov 62H, #085H
mov 63H, #087H
mov 64H, #087H
mov 65H, #085H
mov 66H, #087H
mov 67H, #087H
mov 68H, #087H
mov 69H, #080H
mov 6AH, #087H
mov 6BH, #087H
mov 6CH, #087H
mov 6DH, #087H
mov 6EH, #087H
mov 6FH, #087H

; Initializations
mov R6, #001H			; outer_loop variable

setb PSW.5				; Initially set the flag, and unset it if any check goes wrong

outer_loop: 
	mov A, R6
	mov R3, A			; Initialize value of R7
	mov R4, A
	dec R4				; Initialize R4 to R6-1
	mov A, R4
	mov B, 060H
	mul AB
	mov R2, A			; Initialize R2 to R4*(60H)
	inner_loop:
		; R3 will act both as the column number for upper triangular as well as the loop variable
		mov A, R3
		mov B, 060H
		mul AB
		mov R5, A		; R5 = (60H) * R3 
		
		mov A, #061H
		add A, R2
		add A, R3
		mov R0, A		
		mov 40H, @R0	; Move number from upper triangle to 40H
		
		mov A, #061H
		add A, R4
		add A, R5
		mov R0, A		
		mov A, @R0		; Move number from lower triangle to A
		
		cjne A, 40H, break	; if not equal, then break loop
		
		inc R3
		mov A, R3
		cjne A, 60H, inner_loop
	
	inc R6
	mov A, R2
	add A, 60H
	mov R2, A			; Add m to R2
	inc R4				; Add 1 to R4
	
	mov A, R6
	cjne A, 60H, outer_loop		; Loop till R6 becomes 4

loop : sjmp loop	

break : 
	clr PSW.5					; Clear PSW.5 since unequal numbers found
	ljmp loop
end