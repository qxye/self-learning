%This is a matlab code for self-learning pedestrian detectors in videos
%Qixiang Ye, , 2015, University of Chinese Academy of Sciences
%extracting the HOG features given a group of bounding boxes
function feas = st_featBag(im,bbs)
    feas = [];    
    for i=1:size(bbs,1)
%         x1 = bbs(i,1);
%         y1 = bbs(i,2);
%         x2 = min(size(frame,1),bbs(i,3)+bbs(i,1));
%         y2 = min(size(frame,1),bbs(i,4)+bbs(i,2));
%         im = frame(y1:y2,x1:x2,:);
%         % features of 2 scales
        feas(i,:) = st_fea2scales(im,bbs(i,:));
    end
end