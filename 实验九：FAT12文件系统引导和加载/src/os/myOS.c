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

// *************** root dir ***************

const int ROOTNUM=224, CLUNUM=2838, SECSIZE=512;

extern void read_dir(int i);

int bufcmp(int l,int r,const char *s,int len)
{
	if (l+strlen(s)!=r) return 0;
	for(int i=l; i<r; i++) if (buf[i]!=s[i-l]) return 0;
	return 1;
}

char dirEnt[32];
int find(int l,int r)
{
	int lastDoc=r;
	for(int i=lastDoc-1; i>=l; i--) if (buf[i]=='.') {lastDoc=i; break;}
	for(int i=0; i<ROOTNUM; i++)
	{
		read_dir(i);
		int dirLen=8;
		while (dirLen && dirEnt[dirLen-1]==0) dirLen--;
		if (bufcmp(l,lastDoc,dirEnt,dirLen)==1 && bufcmp(lastDoc+1,r,dirEnt+8,3)==1) return 1;
	}
	return 0;
}

// *************** kernel ***************

extern short next_cluster(short st);
extern void load_client(int seg_addr,short bx,short st);
extern void client_preparation(int seg_addr);
extern void restart();

void ker()
{
	while (1)
	{
		myprintf("\r\n>");
		ReadString();
		head=buflen;
		
		int newPro=0;
		for(int l=0, r=0; l<buflen; l=++r)
		{
			while (r<buflen && buf[r]!='|' && buf[r]!='\r') r++;
			if (l==r) continue;
			if (find(l,r))
			{
				int seg_addr;
				for(int j=0; j<MAXPRO; j++) if (proList[j].state==0)
				{
					newPro=1;
					
					// modify proList
					proList[j].cpuS=emptyCpuState;
					proList[j].cpuS.ip=0x100;
					proList[j].cpuS.cs=proList[j].cpuS.ds=proList[j].cpuS.ss=proList[j].cpuS.es=
						seg_addr=0x2000+(0x800)*j;
					proList[j].cpuS.sp=0x7ffb;
					proList[j].cpuS.flag=512;
					proList[j].pid=++pidTotal;
					for(int k=0; k<8; k++) proList[j].pname[k]=dirEnt[k];
					proList[j].state=2;
					
					// update readyList
					rlTail=(rlTail+1)&MOD_RL_LEN;
					readyList[rlTail]=j;
					
					// load_client
					myprintf("%s: ",proList[j].pname);
					for(short st=(dirEnt[27]<<8)+dirEnt[26], bx=0x100;
						st!=0xFFF;
						st=next_cluster(st), bx+=0x200)
						{
							load_client(seg_addr,bx,st);
							myprintf("%d ",st);
						}
					myprintf("\r\n");
					client_preparation(seg_addr);
					
					break;
				}
			} else if (bufcmp(l,r,"dir",3))
			{
				myprintf("Large     ProgID\r\n");
				for(int i=0; i<ROOTNUM; i++)
				{
					read_dir(i);
					if (dirEnt[12]==1) myprintf("%8d  %.8s.%s\r\n",*(int*)(dirEnt+28),dirEnt,dirEnt+8);
						else break;
				}
			} else
			{
				myprintf("undefined command!\r\n");
			}
		}
		if (newPro)
		{
			curPid=readyList[rlHead];
			restart();
		}
	}
}