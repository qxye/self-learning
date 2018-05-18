/* Hakan Bilen
 * August 5, 2015
 *
 * Implementation of soft-max latent SVM in
 * "Weakly Supervised Object Detection with Posterior Regularization" in 
 * BMVC 2014. 
 *
 * Warning : posterior regularization for symmetry and mutual exclusion are
 * not implemented in this file!
 */
#include <math.h>
#include <limits.h>
#include <omp.h>
#include "mex.h"

/* This function may not exit gracefully on bad input! */

float myLogSumExp(const float * vec, int dim) ;
void computeProb(const float * in, int dim, float * out) ;
{
  /* Variable Declarations */
  
  double *w, f, *g, *y;
  int nVars, nImgs;
  float lambda, beta;
  float lpos2neg,lneg2pos;
  
  /* Get Input Pointers */
  w      = mxGetPr(prhs[0]);
  y      = mxGetPr(prhs[2]);
  lambda = mxGetScalar(prhs[3]);
  beta   = mxGetScalar(prhs[4]);
  
  float np = 0;
  float nn = 0;
  
  nImgs = (int)mxGetNumberOfElements(prhs[2]);
  nVars = (int)mxGetNumberOfElements(prhs[0]);
  
  int        ifield, nfields;
  mwIndex    jstruct;
  mwSize     NStructElems;
  mwSize     ndim;
    
  if(!mxIsStruct(prhs[1]))
    mexErrMsgIdAndTxt( "MATLAB:SLSVMC2:inputNotStruct",
            "Input must be a structure.");
    
  /* get input arguments */
  nfields = mxGetNumberOfFields(prhs[1]);
  NStructElems = mxGetNumberOfElements(prhs[1]);
  
  if (NStructElems!=nImgs)
        mexErrMsgIdAndTxt( "MATLAB:SLSVMC2:WrongNumImgs",
            "Wrong number of images!");
    
  /*number of features (boxes) for each image */
  int * nBoxes = mxCalloc(nImgs,sizeof(int));
  int * cumNBoxes = mxCalloc(nImgs+1,sizeof(int));
  cumNBoxes[0] = 0;

  int i,b,d;
  for(i=1;i<=nImgs;i++) {
    const mxArray *tmp = mxGetFieldByNumber(prhs[1], i-1, 0);
    if(tmp == NULL) {
      mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", 1);
      mexErrMsgIdAndTxt( "MATLAB:data:fieldEmpty",
              "Above field is empty!");
    }
    nBoxes[i-1] = (int)mxGetDimensions(tmp)[1];
    
    if (mxGetDimensions(tmp)[0]!=nVars)
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:wrongDim","Wrong feature dimensionality!");
 
    cumNBoxes[i] = cumNBoxes[i-1] + nBoxes[i-1];
  }  

/*  mexPrintf("X[0,end] %f\n",X[4096]);
  mexPrintf("nImgs %d nVars %d\n",nImgs,nVars);
  mexPrintf("X[2,0] %f\n",X[2*4097]);
  mexPrintf("X[2,end] %f\n",X[3*4097-1]); 
  */
  
  /* Allocated Memory for Function Variables */
/*  plhs[0] = mxCreateDoubleScalar(0); */
  plhs[1] = mxCreateDoubleMatrix(nVars,1,mxREAL);
  g = mxGetPr(plhs[1]);
  
  float * fs = mxCalloc(nImgs,sizeof(float));
  float * gs = mxCalloc(nImgs*nVars,sizeof(float));
  
  /* get number of positives and negatives */
  for(i=0;i<nImgs;i++) {
    if(y[i]>0) {
      np++;
    }
    else if(y[i]<0) {
      nn++;
    }
  }
  
  if (nn==0 || np==0)
     mexErrMsgIdAndTxt( "MATLAB:data:wlabel",
              "No pos or neg label!");
  
  /* balanced loss for pos and neg */
  lpos2neg = 0.5 * (np+nn) / np;
  lneg2pos = 0.5 * (np+nn) / nn;
  

  float ** convProbs = (float **)mxCalloc(nImgs,sizeof(float*));
  float ** concProbs = (float **)mxCalloc(nImgs,sizeof(float*));
  float ** scores    = (float **)mxCalloc(nImgs,sizeof(float*));
  float ** augScores = (float **)mxCalloc(nImgs,sizeof(float*));
  
  for(i=0;i<nImgs;i++) {
    convProbs[i] = (float *)mxCalloc(2*(int)nBoxes[i],sizeof(float));
    concProbs[i] = (float *)mxCalloc((int)nBoxes[i],sizeof(float));
    scores[i]    = (float *)mxCalloc((int)nBoxes[i],sizeof(float));
    augScores[i] = (float *)mxCalloc(2*(int)nBoxes[i],sizeof(float));

  }
  
#pragma omp parallel for schedule(dynamic) private(i)
  for(i=0;i<nImgs;i++) {
    if(y[i]==0)
      continue;
    
    const mxArray *tmp = mxGetFieldByNumber(prhs[1], i, 0);
    if(tmp == NULL) {
      mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", 1);
      mexErrMsgIdAndTxt( "MATLAB:data:fieldEmpty",
              "Above field is empty!");
    }
    const float * x = (float *)mxGetData(tmp);
    int nB = (int)nBoxes[i];
    
    if((int)mxGetDimensions(tmp)[1]!=nB)
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:empty","mxGetDimensions(tmp)[1]!=nB");
    
    if(nB==0)
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:zeroval","zero num bb");
    
    if (mxGetDimensions(tmp)[0]!=nVars)
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:wrongdim","wrong feat dim");
    
    /*    mexPrintf("y[%d] = %f nB %d\n",i,y[i],nB); */
    float concScore = 0;
  
    int b, d;
    
    for(b=0;b<nB;b++) {
      for(d=0;d<nVars;d++) {
        scores[i][b] += (float)w[d] * x[nVars*b+d];
      }
      scores[i][b] *= beta;
    }
    /* concave part */
    if(y[i]>0) {
      concScore = myLogSumExp(scores[i],nB);
      computeProb(scores[i],nB,concProbs[i]);
    }
    else if(y[i]<0) {
      concScore = logf((float)nB);
      for(b=0;b<nB;b++) {
        concProbs[i][b] = 0;
      }
    }
    else {
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:wlabel","wrong label");
    }
    /* convex part */
    if(y[i]>0) {
      for(b=0;b<nB;b++) {
        augScores[i][b] = scores[i][b];
        augScores[i][b+nB] = beta * lpos2neg;
      }
    }
    else if(y[i]<0) {
      for(b=0;b<nB;b++) {
        augScores[i][b] = scores[i][b] + beta * lneg2pos;
        augScores[i][b+nB] = 0;
      }
    }
    else {
      mexErrMsgIdAndTxt("MATLAB:SLSVMC2:wlabel","wrong label");
    }

    computeProb(augScores[i],2*nB,convProbs[i]);
    
    for(b=0;b<nB;b++) {
      float difp = (convProbs[i][b]-concProbs[i][b]);
      for(d=0;d<nVars;d++) {
        gs[i*nVars + d] += x[nVars*b+d] * difp;
      }
    }
    float convScore = myLogSumExp(augScores[i],2*nB);
    fs[i] = convScore - concScore;
  }
  for(i=0;i<nImgs;i++) {
    mxFree(augScores[i]);
    mxFree(scores[i]);
    mxFree(convProbs[i]);
    mxFree(concProbs[i]);
  }
  mxFree(augScores);
  mxFree(scores);
  mxFree(convProbs);
  mxFree(concProbs);

  /* sum objval and grads over all images */
  for(i=0;i<nImgs;i++) {
    if(y[i]==0)
      continue;
    
    f += fs[i];
    for(d=0;d<nVars;d++) {
      g[d] += gs[i*nVars+d];
    }
  }
  for(d=0;d<nVars;d++) {
    g[d] /= (nn+np);
  }
  f /= beta * (nn+np);
  
  /* add regularization */
  for(d=0;d<nVars-1;d++) {
    f += 0.5 * lambda * w[d] * w[d] ;
  }
  
  for(d=0;d<nVars-1;d++) {
    g[d] += lambda * w[d] ;
  }
  mxFree(cumNBoxes);
  mxFree(nBoxes);
  mxFree(gs);
  mxFree(fs);
/*  mxFree(gconcProbs);
  mxFree(gconvProbs);
  mxFree(gscores);
  mxFree(gaugScores); */
 
  plhs[0] = mxCreateDoubleScalar(f);
}

/*---------------------------------------------------------------------------*/
float myLogSumExp(const float * vec, int dim) {
  
  float maxScore = -FLT_MAX ;
  int i=0;
  for (i=0;i<dim;i++) {
    if(maxScore<vec[i])
      maxScore = vec[i];
  }
  float sumScore = 0.f;
  for (i=0;i<dim;i++) {
    sumScore += expf(vec[i]-maxScore);
  }
  return logf(sumScore)+maxScore;
}
/*---------------------------------------------------------------------------*/
void computeProb(const float * in, int dim, float * out) {
  
  float maxScore = -FLT_MAX ;
  
  int i=0;
  for (i=0;i<dim;i++) {
    if(maxScore<in[i])
      maxScore = in[i];
  }
  float sumExp = 0.f;
  for (i=0;i<dim;i++) {
    sumExp += expf(in[i]-maxScore);
  }
  mxAssert(sumExp>0.f,"");
  
  const float rSumExp = 1.f / sumExp;
  for (i=0;i<dim;i++) {
    out[i] = expf(in[i]-maxScore) * rSumExp;
  }
}

