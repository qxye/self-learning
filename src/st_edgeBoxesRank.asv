function [all_bbs, pos_bbs, neg_bbs] = st_edgeBoxesRank(frame, diffImage, fgMask, paras, w, latentW)

%% load pre-trained edge detection model and set opts (see edgesDemo.m)
edgeBox_model=load('edges-master/models/forest/modelBsds'); edgeBox_model=edgeBox_model.model;
edgeBox_model.opts.multiscale=0; edgeBox_model.opts.sharpen=2; edgeBox_model.opts.nThreads=4;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts          = edgeBoxes;
opts.alpha    = .65;     % step size of sliding window search
opts.beta     = .5;     % nms threshold for object proposals
opts.minScore = .01;     % min score of boxes to detect
opts.maxBoxes = 2e2;     % max number of boxes to detect

%% detect EdgeBox proposals (see edgeBoxes.m)
size_min = paras.size_min * size(fgMask,1);
size_max = paras.size_max * size(fgMask,1);
tic, bbs = edgeBoxes(uint8(diffImage),edgeBox_model,opts); toc

%converting into probability
vars = var(bbs(:,5));
maxs = max(bbs(:,5));

%bbs(1:4) rectangle, bbs(5)(7) objectness, bbs(6) motion, bbs(8) combined
bbs(:,5)= 1.0./(1.0+exp(-bbs(:,5)));
val = [];
%combine scores from DPM, edge and background modeling  
for i = 1:size(bbs,1)    
    rect    = bbs(i,:);
    area    = rect(3)*rect(4)+1.0;
    ratio   = rect(4)/rect(3);
    rect(3) = rect(1)+rect(3)-1;
    rect(4) = rect(2)+rect(4)-1;
    patch = fgMask(rect(2):rect(4),rect(1):rect(3));   
    fg_prob(i)   = sum(patch(:))/area/255;      
        
    %foreground score            
    bbs(i,6) = 1.0/(1.0+exp(-fg_prob(i)));    
    bbs(i,7) =0; bbs(i,8) = 0;     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if(fg_prob(i)>paras.bgThreshold)           
       
     if(nargin <6) %first round using edgebox score         
         bbs(i,8)   = w(2)*bbs(i,5)+ w(1)*bbs(i,6);  %sum evaluation         
     else %using latentModel response
         fea       = st_fea2scales(frame,bbs(i,:));
         fea       = [fea 1.0];%keep consitent with latent svm
         score     = fea*latentW;   %object score            
         bbs(i,7)  = 1.0/(1.0+exp(-score));
         bbs(i,8)   = w(3)*bbs(i,5)+w(2)*bbs(i,6)+w(1)*bbs(i,7);   %sum evaluation         
     end         
     
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    val(i)   = bbs(i,8)*10;  
end
toc

%all of the candidate positive bbs
all_bbs = bbs;

%bbs filtering
for i = 1:size(bbs,1)    
    rect    = bbs(i,:);
    area    = rect(3)*rect(4)+1.0;
    ratio   = rect(4)/rect(3);  
    
    %size and ratio filtering
    if(ratio<paras.ratio_min || ratio>paras.ratio_max || ...
            size_min >bbs(i,4) && size_max <bbs(i,4))
        bbs(i,8) = 0;
    end    
end

%rankging positives
[~, idx] = sort(val,'descend');
pos_bbs = bbs(idx,:);
idx = find(pos_bbs(:,8)>0);
pos_bbs = pos_bbs(idx,:);

%two times of candidates
num = min(paras.bbs_num*2, size(pos_bbs,1));
pos_bbs = pos_bbs(1:num,:);

%mining negtive bbs around pos_bbs
neg_bbs = mine_neg_bbs(pos_bbs,size(diffImage));


end
%generate a random sign
function sign = rand_sign()
sign  = rand >0.5;
        if sign==0
            sign = -1;
        end
end

%mining negative bbs that are overlap <0.5 with the positives
function [neg_bbs] = mine_neg_bbs(pos_bbs,sz)

    neg_bbs = [];
    
    for i = 1:size(pos_bbs,1)
        rect  = pos_bbs(i,1:4);
        w     = rect(3);  h     = rect(4);
        
        for j=1:3 %three negative for each positive        
        x = min(sz(2),max(0,rect(1)+w*(rand_sign)/2));
        y = min(sz(1),max(0,rect(2)+h*(rand_sign)/2));        
        bb = [x y min(sz(2),x+w) min(sz(1),y+h)];                        
        bbs= [pos_bbs(:,1) pos_bbs(:,2) pos_bbs(:,3)+pos_bbs(:,1) pos_bbs(:,4)+pos_bbs(:,2) pos_bbs(:,end)];
        %filtering out the bbs that are overlap with any positive >0.5
        %combination and intersection of the box_dpm with all bbs_edge
        x1  = min(bbs(:,1), bb(1));
        y1  = min(bbs(:,2), bb(2));
        x2  = max(bbs(:,3), bb(3));
        y2  = max(bbs(:,4), bb(4));
        xx1 = max(bbs(:,1), bb(1));
        yy1 = max(bbs(:,2), bb(2));
        xx2 = min(bbs(:,3), bb(3));
        yy2 = min(bbs(:,4), bb(4));
        combines  = (x2-x1+1).*(y2-y1+1);
        overlaps  = (xx2-xx1+1).*(yy2-yy1+1);
        ratios    = overlaps./(combines);    
        
        if(isempty(find(ratios >0.5)))   
            neg_rect = [bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2) 0 0 0 0];            
            neg_bbs = [neg_bbs; neg_rect]; 
        end        
        end%j    
        
    end
end

