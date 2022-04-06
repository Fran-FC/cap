#include <stdio.h>
#define N 12
#define BLOCKSIZE 4

void Print_matrix(int C[], int n)
{
   int i, j;

   for (i = 0; i < n; i++)
   {
      for (j = 0; j < n; j++)
         printf("%d\t", C[i + j * n]);
      printf("\n");
   }
} /* Print_matrix */

void comprobar_cpu(int *A, int *sal)
{
   int i, j, res = 1;
   for (j = 1; j < N; j++)
      for (i = 0; i < N - 1; i++)
         if (A[i + j * N] != A[i + 1 + (j - 1) * N])
            res = 0;

   *sal = res;
}

__global__ void comprobar_gpu_optimizado(int *A, bool *sal)
{
   __shared__ bool cache[BLOCKSIZE];
   bool temp_result = true;
   int j = blockIdx.x + 1;
   int tid = threadIdx.x;

   while ((tid < N - 1) && temp_result)
   {
      if (A[tid + j * N] != A[tid + 1 + (j - 1) * N])
         temp_result = false;
      tid += BLOCKSIZE;
   }
   cache[threadIdx.x] = temp_result;

   __syncthreads();
   j = BLOCKSIZE/2;

   while(j!=0)
   {
      if(threadIdx.x < j)
         cache[threadIdx.x] &= cache[threadIdx.x+j];
      __syncthreads();
      j /= 2;
   }
   if(threadIdx.x == 0)
      sal[blockIdx.x] = cache[threadIdx.x];
}

int main()
{
   int i, j;
   int *A = (int *)malloc(N * N * sizeof(int));
   int *sal = (int *)malloc(N * sizeof(int));
   int salcpu;

   // rellenar matriz de numeros en CPU
   for (j = 0; j < N; j++)
      for (i = 0; i < N; i++)
      {
         A[i + N * j] = i + j - 1;
      }
   // A[3+N*4]=77;
   Print_matrix(A, N);
   comprobar_cpu(A, &salcpu);

   if (salcpu == 1)
      printf(" \n La matriz es hankel (cpu)\n");
   else
      printf(" \n La matriz no es hankel (cpu)\n");

   // Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
   //  y lo que sea necesario
   // Comienzo parte GPU
   int *dev_A;
   bool *dev_sal, *sal_gpu = (bool *)malloc(N - 1 * sizeof(bool));

   bool es_hankel = true;

   cudaMalloc((void **)&dev_A, N * N * sizeof(int));
   cudaMalloc((void **)&dev_sal, N - 1 * sizeof(bool));

   cudaMemcpy(dev_A, A, N * N * sizeof(int), cudaMemcpyHostToDevice);

   comprobar_gpu_optimizado<<<N - 1, BLOCKSIZE>>>(dev_A, dev_sal);

   cudaMemcpy(sal_gpu, dev_sal, N - 1 * sizeof(bool), cudaMemcpyDeviceToHost);

   for (i = 0; i < N - 1; i++)
      if (!sal_gpu[i])
         es_hankel = false;

   if (es_hankel)
      printf(" \n La matriz es hankel (gpu)\n");
   else
      printf(" \n La matriz no es hankel (gpu)\n");
}
