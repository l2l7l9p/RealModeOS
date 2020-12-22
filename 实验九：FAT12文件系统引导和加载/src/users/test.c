__asm__(".code16gcc\r\n");
extern char getchar();
extern char getch();
extern void gets(char*);
extern void ReadInt(int*);
extern void putchar(char);
extern void puts(char*);
extern void printf;
// #include"lib_io.h"

int start()
{
	int a,b;
	puts("TEST1: input two number:");
	ReadInt(&a), ReadInt(&b);
	myprintf("the sum is %d\r\n",a+b);
	
	puts("TEST2: input 5 char in one row:");
	for(int i=0; i<5; i++) putchar(getchar());
	getchar();
	
	puts("\r\nTEST3: input a string:");
	char s[50];
	gets(s);
	puts(s);
	
	puts("Finished");
}