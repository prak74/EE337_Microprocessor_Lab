#include <at89c5131.h>
//#include <lcd.h>

Sbit (F1, PSW, 1);
Sbit (F0, PSW, 5);

unsigned int count ;
bit game_over_flag;

/**********************************************************
   uart_init(): 
	Initialization function to be completed
	Initializes UART peripheral for 8-bit transfer, 
	1 start and 1 stop bits. 
	
	Please write TH1 value for required baud rate
***********************************************************/	
void uart_init(void)
{
	TMOD=0x20;							//Configure Timer 1 in Mode 2
	TH1=243;							//Load TH1 to obtain require Baudrate (Refer Serial.pdf for calculations)
	SCON=0x50;							//Configure UART peripheral for 8-bit data transfer 
	TR1=1;								//Start Timer 1
	ES=1;								//Enable Serial Interrupt
	EA=1;								//Enable Global Interrupt
}

/**********************************************************
   Serial_ISR(): 
	Interrupt service routine for UART interrupt.
	Determines whether it is a transmit or receive
	interrupt and raise corresponding flag.
	Transmit or receive functions (defined above) monitor
	for these flags to check if data transfer is done.
***********************************************************/	
void serial_ISR(void) interrupt 4
{
	unsigned char ch = 0;			//Declare and initialize variables
 	
	 if(TI==1)						//check whether TI is set
	{
		TI = 0;						//Clear TI flag
	}
	else if(RI==1)					//check whether RI is set
	{
		RI = 0;						//Clear RI flag
		ch = SBUF;
		if(ch=='q')								// If up character, then execute up command
		{
			game_over_flag = lcd_up(count);
		}
		if(ch=='a')								// If down character. execute down command
		{
			game_over_flag = lcd_down(count);
		}
	}
}
