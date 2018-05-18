mex -O resize.cpp
mex -O dt.cpp
mex -O features.cpp
mex -O getdetections.cpp

% use one of the following depending on your setup
% 1 is fastest, 3 is slowest 

% 1) multithreaded convolution using blas
%mex -O fconvblas.cc -lmwblas -o fconv
% 2) mulththreaded convolution without blas
% mex -O fconvMT.cc -o fconv
% 3) basic convolution, very compatible
 mex -O fconv.cpp -o fconv
