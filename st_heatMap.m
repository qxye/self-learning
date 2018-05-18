%Given and image and the scores of bounding boxes, draw a heatmap according
%to the accumulated scores
function st_heatMap(r, img_size, bbs, strPath,filename)

%rows and cols
rows  = img_size(1);
cols  = img_size(2);

%generate meshgrid
data   = zeros(rows,cols);

min_score = 0;
max_score = 1.0;
%accumulate the scores
for i=1:size(bbs,1)
   x1 = min(bbs(i,1), cols);
   y1 = min(bbs(i,2), rows);
   x2 = min(bbs(i,1)+bbs(i,3), cols);
   y2 = min(bbs(i,2)+bbs(i,4), rows);       
   
   x1 = uint16(x1);
   y1 = uint16(y1);
   x2 = uint16(x2);
   y2 = uint16(y2);
   
   if(bbs(i,end) >0)
   score = (bbs(i,end)-min_score)/(max_score-min_score);   
   data(y1:y2,x1:x2) = (data(y1:y2,x1:x2)+score);
   end
end

img = imresize(data,[100,100*cols/rows]);
img = medfilt2(img,[3 3]);
img = flipud(img);

%generating a heatmap
surf(img),view([0 0, 45]); axis off;
set (gca,'position',[0,0,1,1] );

if(nargin >2)
    saveas(gca,filename,'jpg')    
    dos(['move ' filename '.jpg ' strPath]);
end

end

function drawMap(data,filename)

%generate meshgrid
[Y, X] = meshgrid(1:size(data,1), 1:size(data,2));

%generating a heatmap
surfc(X,Y,data),view([0 0, 45]); axis off;

if(nargin >2)
    saveas(gca,filename,'jpg')
end

end
