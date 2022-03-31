#include <stdio.h>

#define M 100
#define N 100

void printMatrix (int *c)
{
	int i,j;
	for (i=0;i<N;i++)
	{
		for(j=0;j<M;j++)
		{
			printf("%d\t", c[i+M*j]);
		}
		printf("\n");
	}
	printf("\n");
}

__global__ void add(int *a, int *b, int *c)
{
	int tid_x =  threadIdx.x+blockIdx.x*blockDim.x;
	int tid_y =  threadIdx.y+blockIdx.y*blockDim.y;
	int index = tid_x+tid_y*M;
	if(index<N*M)
		c[index]=a[index]+b[index];
}
 
int main() {
	int i,j;
	int a[N*M], b[N*M], c[N*M];
	int *dev_a, *dev_b, *dev_c;

	//reservar memoria en GPU
	cudaMalloc((void **) &dev_a, M*N*sizeof(int) );
	cudaMalloc((void **) &dev_b, M*N*sizeof(int) );
	cudaMalloc((void **) &dev_c, M*N*sizeof(int) );

	//rellenar vectores en CPU
	for (i=0;i<N;i++)
	{
		for(j=0;j<M;j++)
		{
			a[i+M*j]=-i+12*j;
			b[i+M*j]=2*i-j;
		}
	}
	printf("Matrix A:\n");
	printMatrix(a);
	printf("Matrix B:\n");
	printMatrix(b);

	//enviar vectores a GPU
	cudaMemcpy( dev_a, a, M*N*sizeof(int) , cudaMemcpyHostToDevice );
	cudaMemcpy( dev_b, b, M*N*sizeof(int) , cudaMemcpyHostToDevice );
	cudaMemcpy( dev_c, c, M*N*sizeof(int) , cudaMemcpyHostToDevice );

	dim3 g(2,3);
	dim3 bl(4,4);
	//llamar al Kernel
	add<<<g,bl>>>(dev_a,dev_b,dev_c);

	//obtener el resultado de vuelta en la CPU
	cudaMemcpy( c, dev_c, M*N*sizeof(int), cudaMemcpyDeviceToHost );

	printf("Matrix result: \n");
	printMatrix(c);
		
	cudaFree(dev_a) ;
	cudaFree(dev_b) ;
	cudaFree(dev_c) ;
}
	
	
