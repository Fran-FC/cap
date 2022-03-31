#include <stdio.h>
#define N 16
#define BLOCKSIZE 4
void Print_matrix(int C[], int n) {
   int i, j;

   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         printf("%d ", C[i+j*n]);
      printf("\n");
   }
}  /* Print_matrix */

void contar_int(int *A, int *sal, int num1, int num2)
{  int i,j,cant=0;
    for (j=0;j<N;j++)
       for(i=0;i<N-1;i++)
            if ((A[i+j*N]==num1)&&(A[i+1+j*N]==num2))
              cant++;

 *sal=cant;
}

__global__ void contar_cuda(int *A, int *sal, int num1, int num2)
{
    int tid = threadIdx.x;
    sal[tid] = 0;
    
    for (int i=0;i<N-1;i++)
        if((A[i+tid*N] == num1) && (A[i+1+tid*N] == num2))
            sal[tid]++;
}

__global__ void contar_cuda_2(int *A, int *sal, int num1, int num2)
{
    __shared__ int cache[BLOCKSIZE];

    int i;
    int tid_col = blockIdx.x;
    int tid = threadIdx.x;

    sal[tid_col] = 0;

    for (i = tid ; i < N-1; i += blockDim.x)
    {
        if((A[i+tid_col*N] == num1) && (A[i+1+tid_col*N] == num2))
            cache[tid]++;
    }
    if (tid == 0)
        for(i = 0; i < blockDim.x; i++)
            sal[tid_col] += cache[i];
}
 
int main() {
  int i,j;
 
  int *A = (int *) malloc( N*N*sizeof(int) );
  int salcpu;

 //rellenar matriz de caracteres en CPU
  for (j=0;j<N;j++)
    for(i=0;i<N;i++)
      A[i+N*j]=rand()% 10;
     
  Print_matrix(A,N);
  contar_int(A,&salcpu,6,3);
  printf(" \n En cpu se cuentan %d secuencias %d %d ",salcpu, 6,3);

  int *sal= (int *)malloc(N*sizeof(int) ); //variable para copiar resultado de gpu a cpu
  int *dev_A;
  int *dev_sal;
  int sal_gpu = 0;

  cudaMalloc((void **) &dev_A, N*N*sizeof(int) );
  cudaMalloc((void **) &dev_sal, N*sizeof(int) );
  cudaMemcpy(dev_A, A, N*N*sizeof(int), cudaMemcpyHostToDevice);

//   contar_cuda<<<1, N>>>(dev_A, dev_sal, 6,3);
  contar_cuda_2<<<N, BLOCKSIZE>>>(dev_A, dev_sal, 6,3);

  cudaMemcpy( sal, dev_sal, N*sizeof(int), cudaMemcpyDeviceToHost );

  for(i = 0; i < N; i++)
    sal_gpu += sal[i] ;
  printf(" \n En gpu se cuentan %d secuencias %d %d \n",sal_gpu, 6,3);

  free(A);
}