#include <stdio.h>

#define M 10000
#define N 10000

void Print_matrix(double C[], int m, int n) {
   int i, j;

   for (i = 0; i < m; i++) {
      for (j = 0; j < n; j++)
         printf("%.2e ", C[i+j*m]);
      printf("\n");
   }
}
 
__global__ void mediasmatrizcpu(double *A,  double *sal)
{
	int i,j; 
  double suma;

	j = threadIdx.x;
	suma=0;
	for(i = 0; i < M; i++)
		 suma = suma + A[i+j*M];
	sal[j] = suma / double(M);
}

int main() {
	int i,j;
	double *dev_a, *dev_c;
 
  double *A = (double *) malloc( N*M*sizeof(double) );
  double *sal1 = (double *) malloc( N*sizeof(double) );

	cudaMalloc((void **) &dev_a, N*M*sizeof(double) );
	cudaMalloc((void **) &dev_c, N*sizeof(double) );
 
	//rellenar matriz en CPU
  for (j=0;j<N;j++)
		for(i=0;i<M;i++)
		{
			A[i+M*j]=i+j ;
    }

	//Print_matrix(A,M,N);

	//enviar vectores a GPU
	cudaMemcpy( dev_a, A, N*M*sizeof(double) , cudaMemcpyHostToDevice );
	cudaMemcpy( dev_c, sal1, N*sizeof(double) , cudaMemcpyHostToDevice );

  mediasmatrizcpu<<<1,N>>>(dev_a,dev_c);

	//obtener el resultado de vuelta en la CPU
	cudaMemcpy( sal1, dev_c, N*sizeof(double), cudaMemcpyDeviceToHost );

	for (j=0;j<N;j++)
		printf("media columna %d = %f  \n",j,sal1[j]);

  free(A);
  free(sal1);
}
