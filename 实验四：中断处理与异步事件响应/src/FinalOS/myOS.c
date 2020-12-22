__asm__(".code16gcc\r\n");
#include"myOS_IO.c"

void ker()
{
	while (1)
	{
		myprintf("\r\n>");
		ReadString();
		if (buf[0]=='t' && buf[1]=='a' && buf[2]=='b' && buf[3]=='l' && buf[4]=='e' && buflen==5)
		{
			myprintf("  ProgID  Sector   Large\r\n");
			fo(i,1,4) myprintf("%8d%8d%6dKB\r\n",i,i+8,1);
		} else if (buflen==1 && buf[0]>='1' && buf[0]<='4')
		{
			load_client(buf[0]-'0'+8);
		} else
		{
			myprintf("undefined command!\r\n");
		}
	}
	return;
}