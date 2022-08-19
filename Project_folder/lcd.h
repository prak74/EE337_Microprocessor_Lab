/*************************************************
 	lcd.h: Header file for 16x2 LCD interfacing  
**************************************************/

//Functions contained in this header file
void msdelay(unsigned int);												//fn takes integer value as an input and generates corresponding delay in milli seconds
void lcd_init(void);													//Initialize LCD
void lcd_cmd(unsigned int i);											//Sends commands to lcd
void lcd_char(unsigned char ch);										//display character on a lcd corresponding to input ascii
void lcd_write_string(unsigned char *s) reentrant;								//takes pointer of a string which ends with null and display on a lcd 
//void int_to_string(unsigned int,unsigned char *temp_string);			//convert unsigned int to string of corresponding decimal value 
unsigned char lcd_read(unsigned int);									//read contents of the DD RAM address 
unsigned int lcd_up(unsigned int );												//Pushes 'D' to the top row and returns 1 if game_over
unsigned int lcd_down(unsigned int);											//Pushes 'D' to the bottom row and returns 1 if game_over
extern unsigned int count;

//Signals to LCD
sbit RS=P0^0;	//Register select
sbit RW=P0^1;	//Read from or write to register
sbit EN=P0^2;	//Enable pin of lcd


//Function definitions
/************************************************
   lcd_init():
	Initializes LCD port and 
	LCD display parameters
************************************************/
void lcd_init(void)
{
	P2=0x00;
	EN=0;
	RS=0;
	RW=0;
	
	lcd_cmd(0x38);	// Function set: 2 Line, 8-bit, 5x7 dots
	msdelay(4);
	lcd_cmd(0x06);	// Entry mode, auto increment with no shift
	msdelay(4);
	lcd_cmd(0x0C);	// Display on, Curson off
	msdelay(4);
	lcd_cmd(0x01);	// LCD clear
	msdelay(4);
	lcd_cmd(0x80);	//Move cursor to Row 1 column 0
}

/**********************************************************
   msdelay(<time_val>): 
	Delay function for delay value <time_val>ms
***********************************************************/	
void msdelay(unsigned int time)
{
	int i,j;
	for(i=0;i<time;i++)
	{
		for(j=0;j<382;j++);
	}
}


/**********************************************************
    lcd_cmd(<char command>):
	Sends 8 bit command
	LCD display parameters
***********************************************************/	
void lcd_cmd(unsigned int i)
{
	RS=0;
	RW=0;
	EN=1;
	P2=i;
	msdelay(10);
	EN=0;
}


/**********************************************************
   lcd_write_char(<char data>):
	Sends 8 bit character(ASCII)
	to be printed on LCD
***********************************************************/	
void lcd_write_char(unsigned char ch) reentrant
{
	RS=1;
	RW=0;
	EN=1;
	P2=ch;
	msdelay(10);
	EN=0;
}


/***********************************************************
  lcd_write_string(<string pointer>):
	Prints string on LCD. Requires string pointer 
	as input argument.
***********************************************************/	
void lcd_write_string(unsigned char *s) reentrant
{
	while(*s!='\0')
	{
		lcd_write_char(*s++);
	}
}

/***********************************************************
  lcd_read(<DD RAM address>):
	Reads the ascii value of the character present
	at the provided address. If not 'd' or '*'
	then returns 0.
***********************************************************/

unsigned char lcd_read(unsigned int addr) 
{
	unsigned int cmd = 0;						//Declare and initialize variables
	unsigned char i = 0;

	cmd = addr | 0x80;							//Convert address to command
	lcd_cmd(cmd);								//Set address to read from
	msdelay(4);
	
	P2 = 0xff;									//Make P2 input
	EN=0;
	RS=1;
	RW=1;
	EN=1;
	msdelay(10);
	i=P2;
	EN=0;
	if(i!='D' && i!='*')						//If char not 'D' or '*' then irrelevant
	{
		i=0x00;
	}
	return i;
}

/***********************************************************
  lcd_up(<current address of D>):
	Pushes 'D' to the top row, does nothing if D
	already in top row. Returns 1 if top row col 3 
	has '*' in it already.
************************************************************/
unsigned int lcd_up(unsigned int count) 
{
	unsigned char i = 0;			//Declare and initialize variables
	unsigned int up_loc = 0;
	unsigned int down_loc = 0;
	
	up_loc = (0x02+count)%40;
	down_loc = up_loc + 0x40;
	i = lcd_read(up_loc);
	
	if(i == '*')
	{
		return 1;								//If * at upper row, game over
	}
	if(i != 'D')								// If not already D, then " " at bottom and "D" up
	{
		lcd_cmd(down_loc|0x80);
		lcd_write_string(" ");
		lcd_cmd(up_loc|0x80);
		lcd_write_string("D");
	}
	return 0;
}

/***********************************************************
  lcd_down(<current address of D>):
	Pushes 'D' to the bottom row, does nothing if D
	already in bottom row. Returns 1 if bottom row col 3 
	has '*' in it already.
************************************************************/
unsigned int lcd_down(unsigned int count) 
{
	unsigned int up_loc = (0x02+count)%40;
	unsigned int down_loc = up_loc + 0x40;
	
	unsigned char i = lcd_read(down_loc);		//Declare and initialize variables
	
	if(i == '*')
	{
		return 1;				  			//If * at upper row, game over
	}
	if(i != 'D')							// If not already D, then " " at top and "D" below
	{
		lcd_cmd(up_loc|0x80);
		lcd_write_string(" ");
		lcd_cmd(down_loc|0x80);
		lcd_write_string("D");
	}
	return 0;
}