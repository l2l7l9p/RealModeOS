__asm__(".code16gcc\r\n");
#include"myOS_IO.c"

typedef struct cpuState{
	int eax,ebx,ecx,edx,ebp,edi,esi;
	short ip,cs,flag,ds,es,ss,sp;
} cpuState;

cpuState tmpCpuState;

const int sectorNum[6]={0,1,1,1,1,7};

extern void load_client(char cl,int secnum);

void ker()
{
	while (1)
	{
		myprintf("\r\n>");
		ReadString();
		head=buflen;
		if (buf[0]=='t' && buf[1]=='a' && buf[2]=='b' && buf[3]=='l' && buf[4]=='e' && buflen==6)
		{
			myprintf("  ProgID  Sector   Large\r\n");
			fo(i,1,5) myprintf("%8d%8d%6dSec\r\n",i,i+8,sectorNum[i]);
		} else if (buflen==2 && buf[0]>='1' && buf[0]<='5')
		{
			int id=buf[0]-'0';
			load_client(id+8,sectorNum[id]);
		} else
		{
			myprintf("undefined command!\r\n");
		}
	}
}