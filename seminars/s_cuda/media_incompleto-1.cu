#include <stdio.h>
#define N 10

void media(double *a,  double *c)
{
  int i;
  for (i=0;i<N-2;i++)
		c[i]=(a[i]+a[i+1]+a[i+2])/3.0f;
}
 
__global__ void media_cuda(double *a, double *c)
{
	int tid	= blockIdx.x;
	c[tid] = (a[tid]+a[tid+1]+a[tid+2]) / 3.0f;
//	while(tid<N)
//	{
//		c[tid] = (a[tid]+a[tid+1]+a[tid+2]) / 3.0f;
//		tid += 1;
//	}
}

int main() {
	double a[N], c[N];
	double *dev_a, *dev_c;
	int i;

	cudaMalloc((void **) &dev_a, N*sizeof(double) );
	cudaMalloc((void **) &dev_c, N*sizeof(double) );

	//rellenar vectores en CPU
	for (i=0;i<N;i++)
	{
			a[i]=i*i;
			//a[i]=i;
	}

	//enviar vectores a GPU
	cudaMemcpy( dev_a, a, N*sizeof(double) , cudaMemcpyHostToDevice );
	cudaMemcpy( dev_c, c, N*sizeof(double) , cudaMemcpyHostToDevice );

	//llamar al kernel
	int n_blocks = N-2;
	media_cuda<<<n_blocks,1>>>(dev_a, dev_c);

	//obtener el resultado de vuelta en la CPU
	cudaMemcpy( c, dev_c, N*sizeof(double), cudaMemcpyDeviceToHost );

	for (i=0;i<N-2;i++)
		printf("  %f\n",  c[i]);

	cudaFree(dev_a) ;
	cudaFree(dev_c) ;
}
	
	
