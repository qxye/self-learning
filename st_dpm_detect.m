function st_dpm_detect()

global global_path;

globals;

load(testmodel);
fid = fopen(poslist);%测试样本的文件名列表

i =0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(~feof(fid))
   path =fscanf(fid,'%s',[1,1]);      
   i = i+1;
   path = strcat(testdir, path);%测试样本的路径
   path = lower(path);
   out_path = path;
   txtPath  = path;
   out_path = strcat(out_path,'.detect.bmp');
   
   txtPath = strrep(txtPath,'.bmp','');
   txtPath = strrep(txtPath,'.jpg','');
   txtPath = strcat(txtPath,'.txt');
     
   disp(out_path)
   test(path, model,out_path,txtPath);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test(name, model,out_path,txtPath)
cls = model.class;
% load and display image
if exist(name) im = imread(name); end;
if ~im 
    return;
end
%clf;
image(im);
axis equal; 
axis on;
disp('input image');
disp('continuing...');

% load and display model
% visualizemodel(model, 1:2:length(model.rules{model.start}));
% disp([cls ' model visualization']);
% disp('press any key to continue'); pause;
% disp('continuing...');

% detect objects
%imgdetect(input, model, thresh, bbox, overlap) thresh较小时，容易检出，或者误检率高
[dets, boxes] = imgdetect(im, model, -1.0);
top = nms(dets, 0.9);

% get bounding boxes
bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
bbox = clipboxes(im, bbox);
top = nms(bbox, 0.9);
clf;
showboxes(im, bbox(top,:),out_path);
disp('bounding boxes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%写出结果
%write boxes to file, before writing we need to resize the image
if nargin > 2
   imsz = size(im);
  % resize so that the image is 300 pixels per inch
  % and 1.2 inches tall
  scale = 1.2 / (imsz(1)/300);
  im = imresize(im, scale, 'method', 'cubic');
  %f = fspecial('gaussian', [3 3], 0.5);
  %im = imfilter(im, f);
  sized_box = (bbox-1)*scale+1;  
 end

imsize1 = size(im);
fid = fopen(txtPath,'wt');
s = size(top)
fprintf(fid, '%i %i\n\r',imsize1(2),imsize1(1));
for i =1:s
fprintf(fid, '%i %i %i %i\n\r', uint32(sized_box(top(i),1)),uint32(sized_box(top(i),2)),uint32(sized_box(top(i),3)-sized_box(top(i),1))+1,uint32(sized_box(top(i),4)-sized_box(top(i),2))+1);
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%showboxes(im, bbox(top,:),out_path);
fclose(fid);

%imwrite(im,out_path);
%disp('press any key to continue'); pause;
