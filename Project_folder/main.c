#include <at89c5131.h>
#include <stdio.h>
#include <lcd.h>		    //Header file with LCD interfacing functions
#include "serial.c"	        //C file with UART interfacing functions

unsigned int LFSR = 0x01;			//LFSR intially holding (0,0,1)
unsigned int timer_count = 0;			//For creating 1s delays		
unsigned int count = 0;
unsigned int max_count = 0;
extern bit game_over_flag;
bit timer_1s_flag;

/**********************************************************
  delay_1s():
	Generates 1 second delays 
	using Timer 0 in mode 1.
***********************************************************/
void delay_1s(void)			
{
	unsigned int i = 0;
	TH0 = 0x3C;					//Load TH0 and TL0 for 1s delay
	TL0 = 0xB0;
	ET0 = 1;
	for (i; i<40; i++){
		TR0 = 1;				//Start Timer
		while(TF0==0);			//Wait for timer to overflow
		TR0 = 0;				//Pause timer
		TH0 = 0x3C;				//Reload TH0, TL0 values 
		TL0 = 0xB0;
		TF0 = 0;				//Reset Flag
	}
	ET0=0;
	return;
}

/**********************************************************
  find_next_state():
	Generates pseudorandom LFSR values.
	LFSR_next = (b2^b0,b2,b1)
***********************************************************/
unsigned int find_next_state() 
{	
	unsigned int next_state = LFSR;
	
	next_state = (LFSR&7)>>1;
	next_state |= (((LFSR&1)<<2) ^ (LFSR&4));
	return next_state;
}

/**********************************************************
  draw_next(state):
	Draws the next LCD column according to 
	the LFSR value and state (column of pattern).  
***********************************************************/
void draw_next(unsigned int state) 
{
	unsigned char top_pattern[3]={0}, bottom_pattern[3]={0};
	unsigned int top_loc = ((0x0f+count)%40)|0x80;
	unsigned int bottom_loc = (0x40+(0x0f+count)%40)|0x80;
	
	switch(LFSR)
	{
		case 1: 								
				top_pattern[0] = ' ';
				top_pattern[1] = '*';
				top_pattern[2] = '*';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = ' ';
				bottom_pattern[2] = ' ';
				break;
		
		case 4:	
				top_pattern[0] = ' ';
				top_pattern[1] = ' ';
				top_pattern[2] = ' ';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = '*';
				bottom_pattern[2] = '*';
				break;

		case 6:	
				top_pattern[0] = ' ';
				top_pattern[1] = '*';
				top_pattern[2] = ' ';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = ' ';
				bottom_pattern[2] = ' ';
				break;

		case 7:
				top_pattern[0] = ' ';
				top_pattern[1] = ' ';
				top_pattern[2] = ' ';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = ' ';
				bottom_pattern[2] = '*';
				break;

		case 3: 
				top_pattern[0] = ' ';
				top_pattern[1] = ' ';
				top_pattern[2] = ' ';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = '*';
				bottom_pattern[2] = ' ';
				break;
		
		case 5: 
				top_pattern[0] = ' ';
				top_pattern[1] = ' ';
				top_pattern[2] = '*';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = ' ';
				bottom_pattern[2] = ' ';
				break;
		
		case 2: 
				top_pattern[0] = ' ';
				top_pattern[1] = ' ';
				top_pattern[2] = ' ';

				bottom_pattern[0] = ' ';
				bottom_pattern[1] = ' ';
				bottom_pattern[2] = ' ';
				break;		
	}
	
	lcd_cmd(top_loc);							//write pattern according to LFSR and count
	lcd_write_char(top_pattern[state]);
	lcd_cmd(bottom_loc);
	lcd_write_char(bottom_pattern[state]);

	return;
}

/**********************************************************
  action():
	Shifts display by shifting everything left, then moving D right.
	If D collides with *, then returns 1.  
***********************************************************/
unsigned int action() 
{
	unsigned int cmd = 0;				//Declare and initialize variables 
	unsigned int addr_D = (0x02+count)%40;	// 0x02 -> initial position, count -> no. of steps taken, 40-> number of columns in one row
	unsigned int up_or_down = 0;			// if down, thne add 0x40 to addr_D to get the exact address of "D"
	unsigned char temp = 0;
	
	EA = 0;								//Disable interrupts to hold up-down movement of D
	
	//Find and store address of D
	temp = lcd_read(addr_D);
	if(temp !='D')
	{
		up_or_down = 0x40;	
	}

	//Display Shift

	lcd_cmd(0x18);						//Shift display to the left by 1
	
	cmd = (addr_D + up_or_down) | 0x80;				//Convert address to command
	
	//If * at location of D, then game over
	if((addr_D+up_or_down)!=0x27 && (addr_D+up_or_down) != 0x67)		//If addresses are not corner cases
	{
		if(lcd_read((addr_D+1)%40 + up_or_down)=='*')
		{
			return 1;						//Game over
		}
		
		//Else write D back to it's original position and remove the D in second column
		lcd_cmd(cmd);						//Move cursor to old location of D
		lcd_write_string(" D");				//Write " " at old location, and move D to next column
	}
	else			//Corner case addresses (0x27 and 0x67)
	{
		if(lcd_read(up_or_down)=='*')
		{
			return 1;
		}

		lcd_cmd(cmd);
		lcd_write_string(" ");
		lcd_cmd(up_or_down + 0x80);
		lcd_write_string("D");
	}
	
	EA=1;									//Enable interrupts to enable D movement
	return 0;
}

/**********************************************************
  start_game():
	Show the first screen of the game 
	and enables interrupts (user inputs).  
***********************************************************/
void start_game(void) 
{
	//Initializations
	game_over_flag = 0;								//Both flags initially 0
	timer_1s_flag = 0;
	count = 0;							//Keeps track of score
	ES = 1;
	EA = 1;								//Enable interrupts

	//Display game
	lcd_cmd(0x01);						//Clear LCD
	lcd_cmd(0x82);						//Write D at row 1 col 3
	lcd_write_string("D");

	return;
}

/**********************************************************
  score_sceen(void):
	Disables interrupts then shows your score
	and highest score of the session for 3s.  
***********************************************************/
void score_screen(void) 
{
	unsigned char score[16] = {0};				//Declare and initialize variables
	unsigned char highscore[16] = {0};
	
	EA = 0;								//Disable interrupts
	lcd_cmd(0x01);						//Clear screen

	//Show Score 
	lcd_cmd(0x80);	
	if(count<100)					//if score less than 100, then 2 digit score
	{
		sprintf(score,"Score:        %d",count);		
		lcd_write_string(score);
	}
	else 							// 3 digit score
	{
		sprintf(score,"Score:       %d",count);		
		lcd_write_string(score);
	}
	

	//Show Highscore 
	if(max_count<100)
	{
		lcd_cmd(0xC0);	
		sprintf(highscore,"High Score:   %d",max_count);		
		lcd_write_string(highscore);
	}
	else
	{
		lcd_cmd(0xC0);	
		sprintf(highscore,"High Score:  %d",max_count);		
		lcd_write_string(highscore);
	}
	//Wait 3s then return
	EA=1;
	ES=0;			//No serial interrupt
	delay_1s();
	delay_1s();
	delay_1s();
	return;
}



void main(void)
{
	//Initialize port P1 for output from P1.7-P1.4
	P1 = 0x0F;
	
	//Call initialization functions
	lcd_init();
	uart_init();			//Uses T1 for baud rate generation

	//Config T0 for 1s delay interrupts
	TMOD |= 0x01;			//Set mode of T0 to mode 1
	TH0 = 0x3C;
	TL0 = 0x45;

	start_game();

	while(1)
	{
		timer_1s_flag  = 0;								//Redo F1 = 0 before every 1s interval
		ET0 = 1;								//Enable timer interrupts
		TR0 = 1;								//Start timer

		while(game_over_flag == 0 && timer_1s_flag == 0);				//Wait till game over or 1s over

		ET0 = 0;								//Disable Timer Interrupts

		if(game_over_flag == 1)								//If D moved to collide with *
		{										//then F0 set => game over
			score_screen();
			start_game();
			continue;
		}

		game_over_flag = action();					//Proceed to next state
		if(game_over_flag==1)						//If * collided with D then
		{										//game_over_flag = 1
			score_screen();
			start_game();
			continue;
		}
		count++; 
		draw_next(count%3);						//Generate pattern at the end of LCD
		if(max_count<count)
		{
			max_count = count;
		}
		if(count%3 == 0)						// Find state of LFSR every 3s
		{
			LFSR = find_next_state();
		}
		
	}
}

/**********************************************************
  T0_ISR(void):
	Interrupt Service Routine for Timer 0.
	Makes T0 count 50,000 and keeps track of 
	number of overflows. When it reaches 40, 
	sets F1 and pauses timer.  
***********************************************************/
void T0_ISR(void) interrupt 1
{
	timer_count ++;								//Count till 40 for 1s.
	TH0 = 0x3C;
	TL0 = 0xB0;
	if(timer_count == 40)						//Set flag F1 when 1s reached
	{
		timer_count = 0;
		timer_1s_flag = 1;
		TR0 = 0;								//Pause Timer
	}
}