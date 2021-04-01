#include <at89c5131.h>
#include "lcd_test.c"
//#include "serial.c"

sbit LED=P1^7;
unsigned char intr_count = 0,rx_buf = 0;
bit tx_complete = 0;
bit rx_complete = 0;

void serial_ISR(void) interrupt 4
{
		if(TI==1)
		{
			TI = 0;
			tx_complete = 1;
		}
		if(RI==1)
		{
			RI = 0;
			rx_buf = SBUF;
			rx_complete = 1;
			rx_buf = 0;
		}
}

void timer_ISR(void) interrupt 1
{
		intr_count++;
	  LED = ~LED;
}	

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
	//P3 = 0xFF;
	TMOD=0x20;
	T2CON=0x00;
	BDRCON=0x00;
	TH1=-52;
	SCON=0x50;
	PCON|=0x00;
	TR1=1;
	IEN0=0x90;
}

void transmit_char(unsigned char ch)
{
	tx_complete = 0;
	SBUF=ch;
	while(!tx_complete);
	//while(TI!=1);
	//TI=0;
}
unsigned char receive_char(void)
{
	unsigned char ch = 0;
	rx_complete = 0;
	while(!rx_complete);
	ch = SBUF;
	return ch;
}
//unsigned char* receive_string(void)
//{
//	unsigned char index=0;
//	unsigned char *str;
//	do
//	{
//		*(str+index) = receive_char();
//	}
//	while(*(str+index++)!='\n');
//	index--;
//	*(str+index) = '\0';
//	return *str;
//}	

void transmit_string(unsigned char *s)
{
	while(*s!='\0')
	{
		//while(TI!=0);
			transmit_char(*s++);
	}
}

void gpio_test(void)
{
	 P1 = 0x0F;
	 transmit_string("Set switches\n");
	 msdelay(1000);
	 P1 |= P1 << 4;
}	

void led_test(void)
{
		unsigned int i = 0;
		while(i<10)
		{	
			LED = ~LED;
			msdelay(500);
			i++;
		}	
}

void lcd_test(void)
{
	 //unsigned char *str;
	 lcd_cmd(0x80);
	 lcd_write_string("LCD Test");
	 delay_ms(1000);
	 lcd_cmd(0x01);
	 //lcd_cmd(0xC0);
	 //*str = receive_string();
	 //lcd_write_string(str);
}	

void timer_test(void)
{
		while(intr_count < 10);
}

void main(void)
{
	unsigned char ch=0;
	//unsigned char *string;
	P1 = 0x0F;
	port_init();
	lcd_init();
	uart_init();
	//timer_init();
	transmit_string("************************\n");
	transmit_string("******8051 Tests********\n");
	transmit_string("************************\n");
	transmit_string("Press 1 for GPIO test\n");
	transmit_string("Press 2 for LED test\n");
	transmit_string("Press 3 for LCD test\n");
	//transmit_string("Press 4 for Timer test\n");
	
	while(1)
	{
			ch = receive_char();
		  msdelay(100);
			transmit_char(ch);
			lcd_char(ch);
		  //string = receive_string();
		  //transmit_string(string);
			switch(ch)
			{
				case '1':gpio_test();
								 transmit_string("GPIO tested\n");
								 break;
				case '2':led_test();
								 transmit_string("LED tested\n");
								 break;
				case '3':lcd_test();
								 transmit_string("LCD tested\n");
								 break;
				default:transmit_string("Incorrect test.Pass correct number\n");
								 break;
				
			}		
	}
}
