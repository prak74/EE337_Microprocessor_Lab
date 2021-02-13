mov 50H, #063H
mov A, 50H
mov B,#064H				; B = 100

div AB					; given number/100 = digit at 100s location (in A) + remainder (in B)
mov 52H,A				; move 100s digit to 52H
mov A,B					
mov B,#00AH
div AB					; remainder/10 = digit at 10s location (in A) + remainder (in B)

swap A					; move the 10s digits from LSB to MSB
add A,B					; place LSB from B into A
mov 53H,A

here : sjmp here
end