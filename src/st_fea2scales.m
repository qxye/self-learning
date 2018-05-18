%for a given image and bounding boxes, extract 2 scales of HOG features
%the feature extraction procedure is based on DPM toolbox
function fea_mat = st_fea2scales(im,bbs)
%parameters
sbin      = 8; 
pad       = 8;
swid      = 64;%
shei      = 128;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sz = size(im);

fea_mat = [];

%for all bounding boxes to extract features
for i=1:size(bbs,1)

x = bbs(i,1);
y = bbs(i,2);
w = bbs(i,3);
h = bbs(i,4);

padi = single(double(w))/swid*pad;

x1 = max(1,x-padi);
y1 = max(1,y-padi);
x2 = min(size(im,2),x+w+2*padi);
y2 = min(size(im,1),y+h+2*padi);
rect = [x1 y1 x2 y2];
crop = imcrop(im,rect);

if isempty(crop)  crop = im; end;

scale1 = imresize(crop,[shei,swid]);
feat1  = features(double(scale1), sbin);% four bins
scale2 = imresize(scale1, 0.5);
feat2  = features(double(scale2), sbin);%eight bins

fea_mat(i,:) = [feat1(:); feat2(:)];

end