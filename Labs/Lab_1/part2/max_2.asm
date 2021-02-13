mov 040H,#00DH
mov 041H,#01EH
mov 042H,#065H
mov 043H,#0FFH				
mov 044H,#009H
mov 045H,#078H				; Second Largest
mov 046H,#068H
mov 047H,#039H
mov 048H,#0FEH
mov 049H,#016H
mov 04AH,#013H
mov 04BH,#066H
mov 04CH,#07BH				; Largest
mov 04DH,#012H
mov 04EH,#0FDH
mov 04FH,#020H
mov 050H,#03FH
mov 051H,#03BH
mov 052H,#01CH
mov 053H,#062H

mov R1,#040H				; Initialize address in R1
mov 70H,#000H				; Initialize 70 and 71 for a new run
mov 71H,#000H
D:70H FF
start : mov A,@R1
clr C						; Reset C before performing SUBB
SUBB A,70H
JNC max						; if C is 0 => A > 70H => new largest

mov A,@R1					; A was changed by SUBB, reset to @R1
clr C
SUBB A,71H
JNC second_max				; if C is 0 => A > 71H => new second_largest

loop : inc R1
cjne R1,#054H,start			; Loop till R1 becomes 54H

here : sjmp here			; last execution line

max : mov 71H,70H			; max will execute second_largest := largest, largest := current (A)
mov 70H,@R1
sjmp loop

second_max : mov 71H,@R1	; second_max will execute second_largest := current (A)
sjmp loop

end							; EOF