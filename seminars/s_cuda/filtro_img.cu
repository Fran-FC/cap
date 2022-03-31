#include <stdio.h>

#define M 8
#define N 8

#define W (M-2)
#define H (N-2)

void printMatrix (double *c, int m, int n)
{
	int i,j;
	for (i=0;i<n;i++)
	{
		for(j=0;j<m;j++)
		{
			printf("%f ", c[i+m*j]);
		}
		printf("\n");
	}
	printf("\n");
}

__global__ void filter(double *a, double *c)
{
	int tid_x =  threadIdx.x+blockIdx.x*blockDim.x;
	int tid_y =  threadIdx.y+blockIdx.y*blockDim.y;

	int tp_x = tid_x+1;
	int tp_y = tid_y+1;

	int index = tid_x+tid_y*W;
	if(index<W*H)
		c[index]=( a[(tp_x-1)+tp_y*W] + a[(tp_x+1)+tp_y*W] +
							 a[tp_x+(tp_y-1)*W] + a[tp_x+(tp_y+1)*W] +
							 a[tp_x+tp_y*W] ) / 5.0;
	printf("c[%d]=%f\n", index,c[index]);
}
 
int main() {
	int i,j;

	double a[N*M], c[W*H];
	double *dev_a, *dev_c;

	//reservar memoria en GPU
	cudaMalloc((void **) &dev_a, M*N*sizeof(double) );
	cudaMalloc((void **) &dev_c, W*H*sizeof(double) );

	//rellenar vectores en CPU
	for (i=0;i<N;i++)
	{
		for(j=0;j<M;j++)
		{
			a[i+M*j]=-i+12*j;
		}
	}
	printf("Matrix Inp:\n");
	printMatrix(a, M, N);

	//enviar vectores a GPU
	cudaMemcpy( dev_a, a, M*N*sizeof(double) , cudaMemcpyHostToDevice );

	dim3 g(2,2);
	dim3 bl(4,4);
	//llamar al Kernel
	filter<<<g,bl>>>(dev_a, dev_c);

	//obtener el resultado de vuelta en la CPU
	cudaMemcpy( c, dev_c, W*H*sizeof(double), cudaMemcpyDeviceToHost );

	printf("Matrix result: \n");
	printMatrix(c, W, H);
		
	cudaFree(dev_a) ;
	cudaFree(dev_c) ;
}
	
	
