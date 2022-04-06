#include <stdio.h>
#define N 12
#define BLOCKSIZE (N - 1)

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

__global__ void comprobar_gpu(int *A, int *sal)
{
   int i, j, res = 1;
   j = threadIdx.x + 1;
   for (i = 0; i < N - 1; i++)
      if (A[i + j * N] != A[i + 1 + (j - 1) * N])
         res = 0;

   sal[threadIdx.x] = res;
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
   A[3+N*4]=77;
   Print_matrix(A, N);
   comprobar_cpu(A, &salcpu);

   if (salcpu == 1)
      printf(" \n La matriz es hankel (cpu)\n");
   else
      printf(" \n La matriz no es hankel (cpu)\n");

   // Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
   //  y lo que sea necesario
   // Comienzo parte GPU
   int *dev_A, *dev_sal;
   int *sal_gpu = (int *)malloc(BLOCKSIZE * sizeof(int));

   bool es_hankel = true;

   cudaMalloc((void **)&dev_A, N * N * sizeof(int));
   cudaMalloc((void **)&dev_sal, BLOCKSIZE * sizeof(int));

   cudaMemcpy(dev_A, A, N * N * sizeof(int), cudaMemcpyHostToDevice);

   comprobar_gpu<<<1, BLOCKSIZE>>>(dev_A, dev_sal);

   cudaMemcpy(sal_gpu, dev_sal, BLOCKSIZE * sizeof(int), cudaMemcpyDeviceToHost);

   for (i = 0; i < BLOCKSIZE; i++)
      if (sal_gpu[i] == 0)
         es_hankel = false;

   if (es_hankel)
      printf(" \n La matriz es hankel (gpu)\n");
   else
      printf(" \n La matriz no es hankel (gpu)\n");
}
