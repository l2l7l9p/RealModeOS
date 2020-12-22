__asm__(".code16gcc\r\n");

extern char* st;

int count()
{
	int re=0;
	for(int i=0; st[i]!=0; i++) re+=(st[i]=='a');
	return re;
}