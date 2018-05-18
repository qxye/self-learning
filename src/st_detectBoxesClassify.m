%Given bbs of detecting scores and weights, using a classification function
%to classify the bbs into true positives and negatives
% bbs: input bounding boxes
% w  : weights for each factor
%paras: input parameters
function [pos_bbs] = st_detectBoxesClassify(bbs, threshold,xL,yL,xU)

tic,
if(nargin <=1) threshold = 0; end;
if size(bbs,1) <1 pos_bbs = []; return; end;

%graph labeling
yU = graphLabeling(xL, yL, xU);

%classifier thresholding and background filtering
idx = find(bbs(:,8)>threshold & bbs(:,5)>threshold & yU >=0);
%idx = find(bbs(:,8)>threshold & bbs(:,5)>threshold);

pos_bbs = bbs(idx,:);

toc

end

