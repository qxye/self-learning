function demo()
%load('INRIA/inriaperson_final');
%fid = fopen('inria\test\test.txt');
%rootdir = 'car\';
load('Plane\plane_final');
fid = fopen('Plane\test\test6.txt');
%fid = fopen('d:\\1.txt');
i =0;

txtPath = '1.txt';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(~feof(fid))
   filename =fscanf(fid,'%s',[1,1]);  
   %path=['F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\' filename '.png'];
   path=['Plane\' filename '.png'];
   i = i+1;
   path = lower(path);
   out_path = path;
   txtPath  = path;
   out_path = strcat(out_path,'._no3.bmp');
   txtPath = strrep(txtPath,'.bmp','');
   txtPath = strrep(txtPath,'.jpg','');
   txtPath = strcat(txtPath,'.txt');
   %l另建文件夹存储结果
   %out_path = ['F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\result2\re16\' filename '.bmp']; 
   out_path = ['Plane\result2\re16\' filename '.bmp'];
   disp(out_path)
   test(path, model,out_path,txtPath,filename);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test(name, model,out_path,txtPath,filename)
cls = model.class;
% load and display image
im = imread(name);
if ~im 
    return;
end
%clf;
%image(im);
%axis equal; 
%axis on;
disp('input image');
%disp('press any key to continue'); pause;
disp('continuing...');

% load and display model模型可视化
% visualizemodel(model, 1:2:length(model.rules{model.start}));
% disp([cls ' model visualization']);
% disp('press any key to continue'); pause;
% disp('continuing...');

% detect objects
%阈值设置
[dets, boxes] = imgdetect(im, model,0);
%[dets, boxes] = imgdetect(im, model, 0.3);
%top = nms(dets, 0.5);
top = nms(dets, 0.3);
%clf;
% showboxes(im, reduceboxes(model, boxes(top,:)));
% disp('detections');
% disp('press any key to continue'); pause;
% disp('continuing...');

% get bounding boxes
bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
bbox = clipboxes(im, bbox);
top = nms(bbox, 0.3);
%top = nms(bbox, 0.5);
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
%txtPath2=['F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\result\re3\' filename '.txt'];
 %文件夹不存在的创建
txtPath2=['Plane\result\re3\' filename '.txt'];
fid = fopen(txtPath2,'wt');
s = size(top)
%fprintf(fid, '%i %i\n\r',imsize1(2),imsize1(1));
for i =1:s
%fprintf(fid, '%i %i %i %i %f\n\r', uint32(sized_box(top(i),1)),uint32(sized_box(top(i),2)),uint32(sized_box(top(i),3)-sized_box(top(i),1))+1,uint32(sized_box(top(i),4)-sized_box(top(i),2))+1, bbox(top(i),end));
%fprintf(fid, '%i %i %i %i %f\n\r',uint32(bbox(top(i),1)),uint32(bbox(top(i),2)),uint32(bbox(top(i),3)-bbox(top(i),1))+1,uint32(bbox(top(i),4)-bbox(top(i),2))+1,bbox(top(i),end));%修改前留档

fprintf(fid, '%i %i %i %i %f\n\r', uint32(bbox(top(i),1)),uint32(bbox(top(i),2)),uint32(bbox(top(i),3)),uint32(bbox(top(i),4)), bbox(top(i),end));
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%showboxes(im, bbox(top,:),out_path);
fclose(fid);

%imwrite(im,out_path);
%disp('press any key to continue'); pause;
