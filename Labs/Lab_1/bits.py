from random import randint
with open('test.txt','w') as f:
    for i in range(64,84):
        temp = randint(0,127)
        s = "mov {0:03X}H,#{1:03X}H\n".format(i,temp)
        f.write(s)