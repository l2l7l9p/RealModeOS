#include<bits/stdc++.h>
#define fo(i,a,b) for(int i=a;i<=b;i++)
using namespace std;

const int ROOTNUM=224, CLUNUM=2838, SECSIZE=512;

char fat[9*SECSIZE],root[14*SECSIZE];

int getFatEntry(int n)
{
	int pos=(n*3)>>1;
	return (n&1) ?((int)fat[pos+1]<<4)|(fat[pos]>>4) :((int)(fat[pos+1]&15)<<8)|fat[pos] ;
}
void modifyFatEntry(int n,int val)
{
	int pos=(n*3)>>1;
	if (n&1)
	{
		fat[pos+1]=val>>4;
		fat[pos]=(fat[pos]&(0x0F)) | ((val&15)<<4);
	} else
	{
		fat[pos+1]=(fat[pos+1]&(0xF0)) | (val>>8) ;
		fat[pos]=val&255;
	}
}

int d[3005],d0;
char buf[512];
int main(int argc,char *argv[])
{
	FILE *myfloppy=fopen("myfloppy.img","rb+");
	fseek(myfloppy,SECSIZE,SEEK_SET);
	fread(fat,sizeof(char),9*SECSIZE,myfloppy);
	fseek(myfloppy,9*SECSIZE,SEEK_CUR);
	fread(root,sizeof(char),14*SECSIZE,myfloppy);
	
	if (atoi(argv[1])==1)
	{
		FILE *newFile=fopen(argv[2],"rb");
		fseek(newFile,0,SEEK_END);
		int len=ftell(newFile);
		fseek(newFile,0,SEEK_SET);
		
		int rtPos=-1;
		for(int i=0; i<ROOTNUM; i++) if (root[(i<<5)+12]==0)
		{
			rtPos=i<<5;
			break;
		}
		if (rtPos==-1) {puts("Root is full!"); return 0;}
		d[d0=0]=1;
		fo(i,2,CLUNUM) if (getFatEntry(i)==0)
		{
			d[++d0]=i;
			if ((d0<<9)>=len) break;
		}
		if ((d0<<9)<len) {puts("FAT is full!"); return 0;}
		
		int lastDoc=strlen(argv[2]);
		for(int i=lastDoc-1; i>=0; i--) if (argv[2][i]=='.') {lastDoc=i; break;}
		memset(root+rtPos,0,32);
		strncpy(root+rtPos,argv[2],lastDoc);
		strcpy(root+rtPos+8,argv[2]+lastDoc+1);
		root[rtPos+12]=1;
		time_t nowtime;
		time(&nowtime);
		tm *nowtm=localtime(&nowtime);
		*(short*)(root+rtPos+22)=(nowtm->tm_hour<<11)+(nowtm->tm_min<<5)+(nowtm->tm_sec>>1);
		*(short*)(root+rtPos+24)=(nowtm->tm_year<<9)+((nowtm->tm_mon+1)<<5)+(nowtm->tm_mday);
		root[rtPos+26]=d[1]&255;
		root[rtPos+27]=d[1]>>8;
		*(int*)(root+rtPos+28)=len;
		
		for(int i=1; len>0; len-=SECSIZE, i++)
		{
			memset(buf,0,sizeof(buf));
			fread(buf,sizeof(char),SECSIZE,newFile);
			fseek(myfloppy,(d[i]-d[i-1]-1)*SECSIZE,SEEK_CUR);
			fwrite(buf,sizeof(char),SECSIZE,myfloppy);
			modifyFatEntry(d[i],0xFFF);
			if (i>1) modifyFatEntry(d[i-1],d[i]);
		}
		
		fclose(newFile);
	}
	
	fseek(myfloppy,SECSIZE,SEEK_SET);
	fwrite(fat,sizeof(char),9*SECSIZE,myfloppy);
	fwrite(fat,sizeof(char),9*SECSIZE,myfloppy);
	fwrite(root,sizeof(char),14*SECSIZE,myfloppy);
	fclose(myfloppy);
}