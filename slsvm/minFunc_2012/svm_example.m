function svm_example
% options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');
% options.Display = 'iter';

options.Display = 'iter';
%options.Method = 'lbfgs';
%initial
w0 = [-.5; 1];

X = [0 0;
     1 0; 
     2 0;
     0 2;
     1 1];
 Y = [1;1;-1;-1;-1];
 lampta = 1.0;

% define objective function
fun = @(w)loss_func(w,X,Y,lampta);

[w, fval, exitflag, output] = fminunc(fun,w0,options);
%[w] = minFunc(fun,w0,options);

w

end

%SVMµÄËðÊ§º¯Êý£¬ ||W||+sum(error)
function [f g] = loss_func(w,X,Y,lampta)
f= w'*w + lampta*sum(max(0,X*w-Y));
g =0;
end