org 0000h
ljmp start
org 100h
start: mov r1,#0F0H
mov r2,#6AH
loop: inc r1
djnz r2,loop
inc r1
mov 53h,r1
here: sjmp here
end