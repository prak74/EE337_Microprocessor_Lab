#include <at89c5131.h>

void delay_ms(unsigned int time)
{
	int i,j;
	for(i=0;i<time;i++)
	{
		for(j=0;j<382;j++);
	}
}
void uart_init(void)
{
	TMOD=0x20;
	T2CON=0x00;
	BDRCON=0x00;
	TH1=-52;
	SCON=0xD0;
	PCON|=0x00;
	TR1=1;
	IEN0=0x10;
}
void transmit_char(unsigned char ch)
{
	if(TI==0)
	{SBUF=ch;}
	//while(TI!=1);
	//TI=0;
}
void transmit_string(unsigned char *s)
{
	while(*s!='\0')
	{
		while(TI!=0);
			transmit_char(*s++);
	}
}

