% Hakan Bilen
% August 5, 2015
%
% Implementation of soft-max latent SVM in
% "Weakly Supervised Object Detection with Posterior Regularization" in
% BMVC 2014.
%
% Warning : posterior regularization for symmetry and mutual exclusion are
% not implemented in this file!

% download Mark Schmidt's optimization toolbox
if ~exist('minFunc_2012','dir')
  url = 'http://www.cs.ubc.ca/~schmidtm/Software/minFunc_2012.zip';
  unzip(url,'.');
end

% compile it
% run(fullfile('minFunc_2012','mexAll'));
addpath minFunc_2012;
addpath minFunc_2012/minFunc;
addpath minFunc_2012/minFunc/compiled/;

% now compile our c files
% make

% coef l2 regularization ||w||^2 (1/C in SVM)
lambda = single(1e-5);

% softmax beta (default value 1)
beta = single(1);

% write learnt model
modelPath = 'res/Ws.mat';

options.Display = 1;
options.Method = 'lbfgs';

% load train data (don't forget adding 1 as the last bin of your feature for bias)
[featTrain,labelTrain,boxesTrain] = loadFeatures();
nVars = size(featTrain(1).x,1);

% initial solution
W0 = zeros(nVars,1);

% define objective function
funObj = @(w)SLSVMLossC2(w,featTrain,labelTrain,lambda,beta);

% learn soft-max latent svm vector
W = minFunc(funObj,W0,options);

%test
[featTest,labelTest,boxesTest] = loadFeatures();
[scoreSoft,scoreBoxes]         = predict_soft(featTest,W,beta);

% measure average precision (this can be replaced with some other (e.g. accuracy, auc))
% this is classification score
ap = compute_average_precision(scoreSoft,labelTest);
fprintf('test average precision %.2f\n',100 * ap);
bestBoxes = cell(1,numel(featTest));

% if you want to find the best box for an image
for i=1:numel(scoreBoxes)
  [bs,bb] = max(scoreBoxes{i});
  bestBoxes{i} = boxesTest{i}(bb,:);
end


