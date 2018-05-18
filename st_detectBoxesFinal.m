%Given bbs of detecting scores and weights, using a classification function
%to classify the bbs into true positives and negatives
% bbs: input bounding boxes
% w  : weights for each factor
%paras: input parameters
function [pos_bbs] = st_detectBoxesFinal(bbs, threshold)

if(nargin <=1) threshold = 0; end;

if size(bbs,1) <1 pos_bbs = []; return; end;

%classifier thresholding and background filtering
idx = find(bbs(:,6)>0.05 & bbs(:,5)>threshold);
% idx = find(bbs(:,8)>0.4 & bbs(:,5)>threshold);

pos_bbs = bbs(idx,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos_bbs(:,4) = pos_bbs(:,4)*1.0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

