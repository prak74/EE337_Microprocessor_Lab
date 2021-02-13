org 0000h
ljmp start
org 100h
start:
mov r0,#8
mov a,#0B4H
mov b,#02H
mul AB
rep:
rlc a
jnc next
clr c
next:
djnz r0,rep
jz insert
sjmp here
insert:
add a,#86H

here:
sjmp here
end
