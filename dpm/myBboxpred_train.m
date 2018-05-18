function model = myBboxpred_train()
%function model = myBboxpred_train(name, year, method)
% Train a bounding box predictor.
%
% name    class name
% year    dataset year
% method  regression method (default is LS regression)
%name='plane';
%name='inria';
%year='2015';  
method = 'minl2';  %'default'   'minl1'    'rtls'

global g_temploral_flag;
if g_temploral_flag
globals_temporal;
else
globals;
end

%setVOCyear = year;
%pascal_init;
% load final model for class
s = load([cachedir name '_final']);
%s = load([cachedir name '_final']);
sc=struct2cell(s);
model=cell2mat(sc);
%model=rmfield(model,'bboxpred');%移除model里的bboxpred

try
  % test to see if the bbox predictor was already trained
  bboxpred = model.bboxpred;
catch
  % get training data
  [traindets, trainboxes, targets] = bboxpred_data(name);
  % train bbox predictor
  fprintf('%s %s: bbox predictor training...', procid(), name);
  nrules = length(model.rules{model.start});
  bboxpred = cell(nrules, 1);
  for c = 1:nrules
    if isempty(traindets{c}) bboxpred{c}.x1 = 0; bboxpred{c}.y1=0;bboxpred{c}.x2=0; bboxpred{c}.y2=0;continue; end;
    [A x1 y1 x2 y2 w h] = bboxpred_input(traindets{c}, trainboxes{c});
    bboxpred{c}.x1 = getcoeffs(method, A, (targets{c}(:,1)-x1)./w);
    bboxpred{c}.y1 = getcoeffs(method, A, (targets{c}(:,2)-y1)./h);
    bboxpred{c}.x2 = getcoeffs(method, A, (targets{c}(:,3)-x2)./w);
    bboxpred{c}.y2 = getcoeffs(method, A, (targets{c}(:,4)-y2)./h);
  end
  fprintf('done\n');%
  % save bbox predictor coefficients in the model
  model.bboxpred = bboxpred;
  save([cachedir name '_final'], 'model');
end

function beta = getcoeffs(method, X, y)  %method的选项有：default（缺失参数时候），'minl2',    'minl1',     'rtls'
switch lower(method)  %lower：变成小写字母
  case 'default'
    % matlab's magic box of matrix inversion tricks
    beta = X\y;
  case 'minl2'
    % regularized LS regression
    lambda = 0.01;
    Xr = X'*X + eye(size(X,2))*lambda;
    iXr = inv(Xr);
    beta = iXr * (X'*y);
  case 'minl1'
    % require code from http://www.stanford.edu/~boyd/l1_ls/
    addpath('l1_ls_matlab');
    lambda = 0.01;
    rel_tol = 0.01;
    beta = l1_ls(X, y, lambda, rel_tol, true);
  case 'rtls'
    beta = rtlsqepslow(X, y, eye(size(X,2)), 0.2)
  otherwise
    error('unknown method');
end
