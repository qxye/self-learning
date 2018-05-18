%using latent SVM to learn the weight parameters of positive and negative 
%feature bags
function [latentW] = st_latentSVMLearning(pos_bbs_bags, neg_bbs_bags)

% coef l2 regularization ||w||^2 (1/C in SVM)
lambda = single(1e-5);

% softmax beta (default value 1)
beta = single(1);

options.Display = 1;
options.Method = 'lbfgs';

% load train data (don't forget adding 1 as the last bin of your feature for bias)
%[featTrain,labelTrain,boxesTrain] = loadFeatures();
featTrain = []; labelTrain = [];
for i=1:numel(pos_bbs_bags)    
    x =  pos_bbs_bags{i}';       
    % extend to dim to D+1 for bias
    featTrain(i).x = [x;ones(1,size(x,2),'single')];
    labelTrain(i)  = 1;
end

for i=1:numel(neg_bbs_bags)
    x =  neg_bbs_bags{i}';   
    % extend to dim to D+1 for bias
    featTrain(end+1).x = [x;ones(1,size(x,2),'single')];
    labelTrain(end+1)  = -1;
end

nVars = size(featTrain(1).x,1);

% initial solution
W0 = zeros(nVars,1);

% define objective function
funObj = @(w)SLSVMLossC2(w,featTrain,labelTrain,lambda,beta);

% learn soft-max latent svm vector
latentW = minFunc(funObj,W0,options);

%cross validation
for i=1:numel(featTrain)
    score(i)= max(featTrain(i).x'*latentW);    
end

Acc = single(sum(sign(score) == labelTrain))/numel(featTrain);

disp(Acc);

end