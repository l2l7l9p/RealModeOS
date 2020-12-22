__asm__(".code16gcc\r\n");
#include"myprintf.c"

extern char char_askii;
extern char char_kb;
extern void Getchar();
extern void load_client(char cl);

char buf[maxlen];
short buflen;
void ReadString()
{
	for(buflen=0; ; )
	{
		Getchar();
		if (char_askii>=32)
		{
			Put(char_askii);
			buf[buflen++]=char_askii;
		} else if (char_askii==13)
		{
			Put(char_askii);
			Put('\n');
			buf[buflen]=0;
			break;
		}
	}
}

void ker()
{
	while (1)
	{
		Put('\r'), Put('\n'), Put('>');
		ReadString();
		if (buf[0]=='t' && buf[1]=='a' && buf[2]=='b' && buf[3]=='l' && buf[4]=='e' && buflen==5)
		{
			myprintf("  ProgID  Sector   Large\r\n");
			fo(i,1,4) myprintf("%8d%8d%6dKB\r\n",i,i+8,1);
		} else if (buf[0]>='1' && buf[0]<='4')
		{
			load_client(buf[0]-'0'+8);
		} else
		{
			myprintf("undefined command!\r\n");
		}
	}
	return;
}