function demo-tud()
load('INRIA/inriaperson_final');
fid = fopen('d:\\list.txt');
%fid = fopen('d:\\1.txt');
i =0;

txtPath = '1.txt';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(~feof(fid))
   path =fscanf(fid,'%s',[1,1]);      
   i = i+1;
   path = lower(path);
   out_path = path;
   txtPath  = path;
   out_path = strrep(out_path,'D:\tud-test\','d:\testout\');
   txtPath = strrep(txtPath,'D:\tud-test\','d:\testout\');
 
  %out_path = strrep(out_path,'d:\1\','d:\test\testout\');
  %txtPath = strrep(txtPath,'d:\1\','d:\test\testout\');
 
  out_path = strrep(out_path,'.jpg','bmp');
   txtPath = strrep(txtPath,'.bmp','');
   txtPath = strrep(txtPath,'.jpg','');
   txtPath = strcat(txtPath,'.txt');
   %out_path = ['D:\test\testout\' int2str(i) '.bmp'];   
   disp(out_path)
   test(path, model,out_path,txtPath);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test(name, model,out_path,txtPath)
cls = model.class;
% load and display image
im = imread(name);
if ~im 
    return;
end
%clf;
image(im);
axis equal; 
axis on;
disp('input image');
%disp('press any key to continue'); pause;
disp('continuing...');

% load and display model
% visualizemodel(model, 1:2:length(model.rules{model.start}));
% disp([cls ' model visualization']);
% disp('press any key to continue'); pause;
% disp('continuing...');

% detect objects
[dets, boxes] = imgdetect(im, model, 0.3);
top = nms(dets, 0.5);
%clf;
% showboxes(im, reduceboxes(model, boxes(top,:)));
% disp('detections');
% disp('press any key to continue'); pause;
% disp('continuing...');

% get bounding boxes
bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
bbox = clipboxes(im, bbox);
top = nms(bbox, 0.5);
clf;
showboxes(im, bbox(top,:),out_path);
disp('bounding boxes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%д�����
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
