function [scoreSoft,scores] = predict_soft(feat,w,beta)
% PREDICT_SOFT computes softmax score for an image
% log sum_b exp(beta*w*feat(b))

% D feature dimensionality
% w(D,1) - last bin is bias
% feat (1xnumImgs) features
% feat(i) (D,nBoxes)

% scoreSoft (numImgsx1) classification score for each image
% score for each box

numImgs = numel(feat);


scoreSoft = zeros(numImgs,1);
scores = cell(numImgs,1);
for i=1:numImgs
%   scores_i = scores(idxB(i)+1:idxB(i+1));
  scores{i} = feat(i).x' * w;
  scoreSoft(i,:) = mylogsumexp(beta*scores{i});
end


function [y,E,xmax] = mylogsumexp(x)
xmax = max(x,[],1);
E = exp(bsxfun(@minus,x,xmax));
y = log(sum(E(:))) + xmax;