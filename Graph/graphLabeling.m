%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%using laplacian regularization for two class sem-supervised labeling
%xL; labeled instance feature vectors, row vector
%yL; labels
%xU: unlabeled instance feature vectors
%yU: returned labels for xU
%copyright: free for all academic purpose,but not for commercial purpose
%2015-07-01 by Qixiang Ye, qxye@ucas.ac.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yU = graphLabeling(xL, yL, xU, K)

if nargin <=3 K = 5;end

%construct a kNN graph, COMPUTE PAIRWISE DISTANCES & FIND NEIGHBORS 
NL= size(xL,1);
NU= size(xU,1);

X = [xL;xU]; 
[n,dim] = size(X);
A = sparse(n,n);
step = 100;  
for i1=1:step:n    
    i2 = i1+step-1;
    if (i2> n) 
      i2=n;
    end;
    XX= X(i1:i2,:);  
    dt = L2_distance(XX',X',0);
    [Z,I] = sort ( dt,2);
    for i=i1:i2
      for j=2:K+1
	        A(i,I(i-i1+1,j))= Z(i-i1+1,j); 
	        A(I(i-i1+1,j),i)= Z(i-i1+1,j); 
      end;    
    end;
end;
W = A;
[A_i, A_j, A_v] = find(A);  % disassemble the sparse matrix
for i = 1: size(A_i)  
    W(A_i(i), A_j(i)) = 1;
end;

D = sum(W(:,:),2);   
L = spdiags(D,0,speye(size(W,1)))-W;

%computing the L_ll L_ul and Luu and then the predicted labels by graph
%regulazation
L_ll  = L(1:NL,1:NL);
L_ul  = L(NL+1:end,1:NL);
L_uu  = L(NL+1:end,NL+1:end);

yU    = -full(inv(L_uu))*L_ul*yL;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yU(yU>-0.5)  = 1;
yU(yU<=-0.5) = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

function d = L2_distance(a,b,df)
if (size(a,1) == 1)
  a = [a; zeros(1,size(a,2))]; 
  b = [b; zeros(1,size(b,2))]; 
end
aa=sum(a.*a); bb=sum(b.*b); ab=a'*b; 
d = sqrt(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab);
d = real(d); 
if (df==1)
  d = d.*(1-eye(size(d)));
end
end