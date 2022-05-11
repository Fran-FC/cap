#include <stdio.h>
#include <stdlib.h>
#include "ctimer.h"

void matprod(double *A, double *B, double *C, int n)
{
	#pragma omp parallel for
	for(int j = 0; j < n; j++)
	{
		for(int k = 0; k < n; k++)
		{
			for(int i = 0; i < n; i++)
			{
				C[i+j*n] = C[i+j*n] + A[i+k*n] * B[k+j*n];
			}
		}
	}
}

void print_matrix(double *M, int n)
{
	for(int i = 0; i < n; i++)
	{
		printf("\n");
		for(int j = 0; j < n; j++)
		{
			printf(" %f", M[i+j*n]);
		}
	}
	printf("\n");
}

int main() { 
  int n=10;
  /* Reservamos memoria para los datos */
  double *A = (double *) malloc( n*n*sizeof(double) );
  double *B = (double *) malloc( n*n*sizeof(double) );
  double *D = (double *) calloc( 0, n*n*sizeof(double) );  
	print_matrix(D, n);
  double *C = (double *) malloc( n*n*sizeof(double) );

  /* Lo probamos */
  int i, j;
  for( j=0; j<n; j++ ) { 
    for( i=0; i<n; i++ ) { 
      A[i+j*n] = ((double) rand()/ RAND_MAX);
    }   
  }
  for( j=0; j<n; j++ ) { 
    for( i=0; i<n; i++ ) { 
      B[i+j*n] = ((double) rand()/ RAND_MAX);
    }   
  }   

  double elapsed, ucpu, scpu;
  ctimer_(&elapsed,&ucpu,&scpu);
  matprod( A, B, C, n );
  ctimer_(&elapsed,&ucpu,&scpu);
  printf("Elapsed: %f seconds\n", elapsed);

	/**
	printf("Result: \n");
	print_matrix(C, n);
	printf("\n");
	**/

  /* Liberamos memoria */
  free(A);
  free(B);
  free(C);
  return 0;
}
