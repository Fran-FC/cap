#include <stdio.h>

int main()
{
	int *p;
	for(int i = 0; i < 100000000000000000000000; i++)
	{
		p++;
		p = &i;
	}
	printf("Puntero: %p\n", p);
	printf("Contenido: %d\n", p[9]);

}
