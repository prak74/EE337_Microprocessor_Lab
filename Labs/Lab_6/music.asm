org 0000H
ljmp init

org 000BH
cpl P0.0
mov TH0, R0
mov TL0, R1
reti


org 0100H
init:
	; Enable Interrupts
	setb EA
	setb ET0
	
	; Initialize Timers
    mov TMOD, #011H             ; T0 in 16-bit, T1 in 16-bit count


main:
    mov TH0, #0F1H
    mov TL0, #087H
	mov R0, #0F1H
    mov R1, #087H
    setb TR0
    acall delay_2s
    clr TR0
    mov TH0, #0F2H
    mov TL0, #0FBH
	mov R0, #0F2H
    mov R1, #0FBH
    setb TR0
    acall delay_2s
    ljmp main
    
delay_2s:
    mov R2, #80
    loop:
		mov TH1, #03CH
		mov TL1, #0A5H
        setb TR1
        here : jnb TF1, here
        clr TF1
        djnz R2, loop
    ret
end