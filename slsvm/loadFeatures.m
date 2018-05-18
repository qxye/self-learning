function [feat,labels,boxes] = loadFeatures()
% LOADFEATURES generates an toy dataset
% D feature dimensionality (4096 in the paper)
% N number of images
% nbi number of bounding boxes in image i
% feat 1xN cell
% feat(i).x Dxnbi "single" matrix for image i


% number of images
N = 10;

% dimensionality of features
D = 2;

% only binary labels {-1,1} allowed (1xN)
labels = double(2*(randi(2,1,N)-1)-1);

% ensure that there are both pos and neg data
if all(labels)==1 || all(labels)==-1
  labels(1) = -labels(1);
end
% bounding boxes (not used in learning explicitly)
boxes = cell(1,N);

% features
feat = struct([]);

for i=1:N
  % random number of boxes
  nb = randi(3);
  
  % this is not used in learning (you can upload your bounding box coordinates
  % for computing detection score (not implemented yet!))
  boxes{i} = ones(nb,4);
  
  % x (D x N)
  if labels(i)>0
    x = 1 + 0.5 * randn(D,nb,'single');
  else
    x = -1 + 0.5 * randn(D,nb,'single');
  end
  
  % normalize l2 == 1
  x = bsxfun(@rdivide,x,sqrt(sum(x.^2,1)));
  
  % extend to dim to D+1 for bias 
  feat(i).x = [x;ones(1,size(x,2),'single')];
  
  % to be sure :)
  feat(i).x = single(feat(i).x);
end


