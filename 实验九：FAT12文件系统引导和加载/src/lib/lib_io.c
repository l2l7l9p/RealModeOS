__asm__(".code16gcc\r\n");
#include<stdarg.h>
#define fo(i,a,b) for(int i=a;i<=b;i++)
#define fd(i,a,b) for(int i=a;i>=b;i--)
#define maxlen 105

typedef unsigned int uint;

// ********************* string function **************

int strlen(const char *s)
{
	int re=0;
	while (s[re]!=0) re++;
	return re;
}

// ********************* output **************

int d0,len,ali,width;
char S[maxlen],d[maxlen];

extern void putchar(char ch);
// void putchar(char ch)
// {
	// __asm__ __volatile__(
		// "movb %0, %%al ;"
		// "movb $0, %%ah ;"
		// "int $0x21 ;"
		// ::"a"(ch)
	// );
// }

void puts(char *s)
{
	int len=strlen(s);
	for(int i=0; i<len; i++) putchar(s[i]);
	putchar('\r'), putchar('\n');
}

void PutString(char *S,int limit)
{
	int len=strlen(S);
	if (limit>-1 && limit<len) len=limit;
	if (ali) fo(i,1,width-len) putchar(' ');
	fo(i,0,len-1) putchar(S[i]);
	if (!ali) fo(i,1,width-len) putchar(' ');
}

void PutChar(char ch)
{
	S[0]=ch, S[1]='\000';
	PutString(S,-1);
}

void PutInt(int x,int limit)
{
	if (x<0)
	{
		S[len++]='-';
		x=-x;
	}
	if (x==0) d[d0=1]=0;
		else for(d0=0; x; x/=10) d[++d0]=x%10;
	
	fo(i,1,limit-d0) S[len++]='0';
	fd(i,d0,1) S[len++]=d[i]+'0';
	S[len++]='\000';
	PutString(S,-1);
}

void PutUInt(uint x,int ty,int cap,int limit)
{
	if (x==0) d[d0=1]=0;
		else for(d0=0; x; x/=ty) d[++d0]=x%ty;
	
	fo(i,1,limit-d0) S[len++]='0';
	fd(i,d0,1) S[len++]=(d[i]<10) ?d[i]+'0' :d[i]-10+(cap?'A':'a');
	S[len++]='\000';
	PutString(S,-1);
}

void myprintf(const char format[],...)
{
	int n=strlen(format);
	va_list ap;
	va_start(ap,format);
	
	fo(i,0,n-1) if (format[i]=='%' && i<n-1)
	{
		int now=i;
		
		ali=1, width=0;
		int acr=0, hasacr=0, h=0, l=0, get;
		while (format[i+1]=='-') ali=0, i++;
		while (format[i+1]>='0' && format[i+1]<='9') width=width*10+format[++i]-'0';
		if (format[i+1]=='.') hasacr=1, i++;
		if (format[i+1]=='-') i++;
		while (format[i+1]>='0' && format[i+1]<='9') acr=acr*10+format[++i]-'0';
		if (format[i+1]=='h') h=1, i++;
		if (format[i+1]=='l') l=1, i++;
		
		len=0;
		switch (format[++i]) {
			case 'd': case 'i':
				get= h ?(short)va_arg(ap,int) :va_arg(ap,int) ;
				PutInt(get,acr);
				break;
			case 'x': case 'X':
				get= h ?(short)va_arg(ap,uint) :va_arg(ap,uint) ;
				PutUInt(get,16,(format[i]=='X'),acr);
				break;
			case 'u':
				get= h ?(short)va_arg(ap,uint) :va_arg(ap,uint) ;
				PutUInt(get,10,0,acr);
				break;
			case 'c':
				PutChar(va_arg(ap,int));
				break;
			case 's':
				PutString(va_arg(ap,char*),(hasacr)?acr:-1);
				break;
			case 'p':
				PutUInt((uint)va_arg(ap,void*),16,0,8);
				break;
			case '%':
				putchar('%');
				break;
			default:
				fo(j,now,i) putchar(format[j]);
		}
	} else putchar(format[i]);
	
	va_end(ap);
}

// ********************* input **************

extern char getch();
// char getch()
// {
	// __asm__ __volatile__(
		// "movb $2, %%ah ;"
		// "int $0x21 ;"
		// "movzx %%al, %%eax"
		// ::
	// );
// }
extern char getchar();
// char getchar()
// {
	// __asm__ __volatile__(
		// "movb $1, %%ah ;"
		// "int $0x21 ;"
		// "movzx %%al, %%eax"
		// ::
	// );
// }

void gets(char *s)
{
	int len=0;
	for(char ch=getchar(); ch!='\r'; ch=getchar()) s[len++]=ch;
	s[len]=0;
}

void ReadInt(int *data)
{
	*data=0;
	char ch=getchar(), neg=0;
	while ((ch<'0' || ch>'9') && ch!='-') ch=getchar();
	if (ch=='-') neg=1, ch=getchar();
	do{
		*data=(*data<<3)+(*data<<1)+ch-'0';
		ch=getchar();
	} while (ch>='0' && ch<='9');
	if (neg==1) *data=-*data;
}