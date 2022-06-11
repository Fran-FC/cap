#include "mex.h"

void iterac(double *in, double *out, double *dt, double *alp, double *dx, mwSize n)
{
	mwSize i,j;
	for (i=1; i<n-1; i++) 
		for(j=1;j<n-1; j++)
			{
				out[i+j*n]= in[i+j*n]+(in[i-1+j*n]+in[i+1+j*n]+in[i+(j-1)*n]+in[i+(j+1)*n]-4*in[i+j*n])*(*dt)*(*alp)/((*dx)*(*dx));        
			}
}

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *in, *out, *dt, *alp, *dx;
	size_t n_size;

	size_t mrows, ncols;

	if(nrhs != 5)
		mexErrMsgIdAndTxt ("MATLAB:iterac:invalidNumInputs", "6 input required.");	
	else if(nlhs > 1)
		mexErrMsgIdAndTxt ("MATLAB:iterac:maxlhs", "Too many out args.");	

	mrows = mxGetM (prhs[0]);
	ncols = mxGetN (prhs[0]);

	if(!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
			!(mrows == ncols))
		mexErrMsgIdAndTxt ("MATLAB:iterac:inputNotCorrect", "Matrix not square");	

	plhs[0] = mxCreateDoubleMatrix((mwSize)mrows, (mwSize)ncols, mxREAL);

	in = mxGetPr(prhs[0]);
	dt = mxGetPr(prhs[1]);
	alp = mxGetPr(prhs[2]);
	dx = mxGetPr(prhs[3]);
	
	out = mxGetPr(plhs[0]);

	iterac(in, out, dt, alp, dx, (mwSize)mrows);
}
