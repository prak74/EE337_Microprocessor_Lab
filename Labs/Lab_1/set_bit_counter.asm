mov 70H, #0AAH					; Assign value to 70H
mov A, 70H						; Move 70h to A
mov R0,#08H						; Initialize R0 to 8 (since 8 bits => 8 steps)
check : jb ACC.0,increment		; If ACC.0 set, move to increment
loop : rr A						; right rotate to get next bit at ACC.0
djnz R0,check					; repeat check and loop till R0 = 0
here : sjmp here				; Last line to be executed
increment : inc 71H				; If ACC.0, inc 71H
sjmp loop						; Go back to loop
end								; EOF