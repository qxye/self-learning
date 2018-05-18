function example2

options = optimoptions('fmincon','Algorithm','interior-point','Display','iter','GradObj','on','GradConstr','on');
options.Display = 'iter';
%initial
x0 = [-.5; 0];

[x, fval, exitflag, output] = fmincon(@f1,x0,[],[],[],[],[],[],@g1,options);

end

function [f,gf] = f1(x)
% ONEHUMP Helper function for Tutorial for the Optimization Toolbox demo

%   Copyright 2008-2009 The MathWorks, Inc.

r = x'*x;%x(1)^2 + x(2)^2;
s = exp(-r);
f = x(1)*s+r/20;

if nargout > 1
   gf = [(1-2*x(1)^2)*s+x(1)/10;
       -2*x(1)*x(2)*s+x(2)/10];
end
end

function [c,ceq,gc,gceq] = g1(x)
% TILTELLIPSE Helper function for Tutorial for the Optimization Toolbox demo

%   Copyright 2008-2009 The MathWorks, Inc.

c = x(1)*x(2)/2 + (x(1)+2)^2 + (x(2)-2)^2/2 - 2;
ceq = [];

if nargout > 2
   gc = [x(2)/2+2*(x(1)+2);
       x(1)/2+x(2)-2];
   gceq = [];
end

end



