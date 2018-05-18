function [all_bbs neg_bbs pos_bbs] = st_detectBoxesRank(diffImage,edgeBox_model, paras, fgMask,w,bbs_dpm)
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
if(nargin <2)
edgeBox_model=load('models/forest/modelBsds'); edgeBox_model=edgeBox_model.model;
edgeBox_model.opts.multiscale=0; edgeBox_model.opts.sharpen=2; edgeBox_model.opts.nThreads=4;
end

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts          = edgeBoxes;
opts.alpha    = .65;     % step size of sliding window search
opts.beta     = .5;     % nms threshold for object proposals
opts.minScore = .01;     % min score of boxes to detect
opts.maxBoxes = 2e2;     % max number of boxes to detect
%% detect EdgeBox proposals (see edgeBoxes.m)
%paras.size_min = paras.size_min * size(fgMask,1);
%paras.size_max = paras.size_max * size(fgMask,1);
size_min = paras.size_min * size(fgMask,1);
size_max = paras.size_max * size(fgMask,1);

tic, bbs_edge=edgeBoxes(uint8(diffImage),edgeBox_model,opts); toc

if(nargin <6)   bbs  = bbs_edge;%the first round
else            bbs = bbs_dpm;
end

%converting into probability
vars = var(bbs(:,5));
maxs = max(bbs(:,5));
object_prob=1.0/sqrt(2*pi*vars)*exp(-(bbs(:,5)-maxs).*(bbs(:,5)-maxs)/(2*vars));
object_prob=min(object_prob,1.0);

val = [];
%combine scores from DPM, edgebox and background modeling  
for i = 1:size(bbs,1)    
    rect    = bbs(i,:);
    area    = rect(3)*rect(4)+1.0;
    ratio   = rect(4)/rect(3);
    rect(3) = rect(1)+rect(3)-1;
    rect(4) = rect(2)+rect(4)-1;
    patch = fgMask(rect(2):rect(4),rect(1):rect(3));   
    fg_prob(i)   = sum(patch(:))/area/255;      
        
    %foreground score            
    bbs(i,6) = fg_prob(i); bbs(i,7) =0; bbs(i,8) = 0;     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(nargin <6)
        if(ratio>paras.ratio_min && ratio<paras.ratio_max &&...
        size_min <bbs(i,4) && size_max >bbs(i,4) && fg_prob(i)>paras.bgThreshold)           
    
        bbs(i,6)   = fg_prob(i);       %foreground score
        bbs(i,7)   = object_prob(i);   %object score            
        bbs(i,8)   = w(2)*bbs(i,6)+w(3)*bbs(i,7);   %sum evaluation         
        end
    else     
    %DPM score
    [bbs(i,7) rect] = getDetectResponse(bbs_dpm(i,:),bbs_edge);                         
    %bbs(i,9:12) = rect(1:4);     
    %sum evaluation  
    bbs(i,8) = w(1)*bbs(i,5)+w(2)*bbs(i,6)+w(3)*bbs(i,7);  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    end    
    
    val(i)   = bbs(i,8)*10;  
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%intra-frame latent model learning with graph constraint
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rankging positives
[~, idx] = sort(val,'descend');
pos_bbs = bbs(idx,:);
all_bbs = bbs(idx,:);
idx = find(pos_bbs(:,5)>0);
pos_bbs = pos_bbs(idx,:);

num = min(paras.bbs_num, size(pos_bbs,1));
pos_bbs = pos_bbs(1:num,:);

%getting negtives from low score positives
neg_num = min(paras.bbs_num, size(pos_bbs,1));
neg_bbs = bbs(end-neg_num:end,:);
%% show top rank results
end

%getting the objectness response of one box
function [res rect] = getDetectResponse(box, bbs)
%converting bbs format from (x1 y1 wid hei) to (x1 y1 x2 y2)
bb  = [box(1) box(2) box(3)+box(1) box(4)+box(2)];
bbs2= [bbs(:,1) bbs(:,2) bbs(:,3)+bbs(:,1) bbs(:,4)+bbs(:,2) bbs(:,end)];

%combination and intersection of the box_dpm with all bbs_edge
x1  = min(bbs2(:,1), bb(1));
y1  = min(bbs2(:,2), bb(2));
x2  = max(bbs2(:,3), bb(3));
y2  = max(bbs2(:,4), bb(4));
xx1 = max(bbs2(:,1), bb(1));
yy1 = max(bbs2(:,2), bb(2));
xx2 = min(bbs2(:,3), bb(3));
yy2 = min(bbs2(:,4), bb(4));

combines  = (x2-x1+1).*(y2-y1+1);
overlaps  = (xx2-xx1+1).*(yy2-yy1+1);
ratios    = overlaps./(combines);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx = find(ratios >0.25);
valid_bbs = bbs2(idx,:);
old_valid_bbs   = bbs(idx,:);

if~isempty(valid_bbs)
[res idx] = max(valid_bbs(:,end));%max response

%remember the proposal localtion
rect = old_valid_bbs(idx,1:4);

else res = 0; rect =[0 0 0 0];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
