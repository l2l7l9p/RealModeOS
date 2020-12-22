__asm__(".code16gcc\r\n");
#include"myOS_IO.c"

// *************** multi-process manage ***************

typedef struct cpuState{
	int eax,ebx,ecx,edx,ebp,edi,esi;
	short ip,cs,flag,ds,es,ss,sp;
} cpuState;

typedef struct PCB{
	cpuState cpuS;
	char pid,pname[10],state;	// state: 0--empty; 1--running; 2--ready
} PCB;

#define MAXPRO 10
#define MAX_RL_LEN 16
#define MOD_RL_LEN 15

cpuState emptyCpuState;
PCB proList[MAXPRO+1];
char pidTotal;
int readyList[MAX_RL_LEN],rlHead=1,rlTail,curPid=MAXPRO;

void ProSchedule()				// process scheduling
{
	if (curPid==MAXPRO) return;
	if (proList[curPid].state==0) rlHead=(rlHead+1)&MOD_RL_LEN;
		else if (proList[curPid].state==2)
		{
			rlTail=(rlTail+1)&MOD_RL_LEN;
			readyList[rlTail]=readyList[rlHead];
			rlHead=(rlHead+1)&MOD_RL_LEN;
		}
	curPid= (rlHead==((rlTail+1)&MOD_RL_LEN)) ?MAXPRO :readyList[rlHead] ;
}

// *************** kernel ***************

const int sectorNum[6]={0,1,1,1,1,7};

extern void load_client(int seg_addr,short bx,short dx,short cx);
extern void client_preparation(int seg_addr);
extern void restart();

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
			fo(i,1,5) myprintf("%8d%8d%6dSec\r\n",i,i+11,sectorNum[i]);
		} else if (buf[0]>='1' && buf[0]<='5')
		{
			for(int i=0; i<buflen; i+=2) if (buf[i]>='1' && buf[i]<='5')
			{
				int id=buf[i]-'0', st=id+11, seg_addr;
				for(int j=0; j<MAXPRO; j++) if (proList[j].state==0)
				{
					// modify proList
					proList[j].cpuS=emptyCpuState;
					proList[j].cpuS.ip=0x100;
					proList[j].cpuS.cs=proList[j].cpuS.ds=proList[j].cpuS.ss=proList[j].cpuS.es=
						seg_addr=0x2000+(0x800)*j;
					proList[j].cpuS.sp=0x7ffb;
					proList[j].cpuS.flag=512;
					proList[j].pid=++pidTotal;
					proList[j].pname[0]=id+48;
					proList[j].state=2;
					
					// update readyList
					rlTail=(rlTail+1)&MOD_RL_LEN;
					readyList[rlTail]=j;
					
					// load_client
					for(short num=sectorNum[id], bx=0x100, ch=st/36, dh=(st/18)&1, cl=(st%18)+1;
						num;
						num--, bx+=0x200, ch+=(dh==1 && cl==18), dh^=(cl==18), cl=(cl%18)+1)
							load_client(seg_addr,bx,dh<<8,(ch<<8)+cl);
					client_preparation(seg_addr);
					
					break;
				}
			}
			curPid=readyList[rlHead];
			restart();
		} else
		{
			myprintf("undefined command!\r\n");
		}
	}
}