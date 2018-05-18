function [bbs] = st_dpm_detect_img(im,det_threshold, nms_threshold,strDetFilePath)

global global_path;

global g_temploral_flag;
if g_temploral_flag
globals_temporal;
else
globals;
end

% load and display the object detect model
if length(who('model') )<=0 
load(testmodel);
%visualizemodel(model, 1:2:length(model.rules{model.start}));
end

%detect objects
[dets, boxes] = imgdetect(im, model, det_threshold);
%top = nms(dets, nms_threshold);
%get bounding boxes
bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
bbox = clipboxes(im, bbox);

top = nms2(bbox, nms_threshold);
bbox= bbox(top,:);

clf;

%showboxes(im, bbox(top,:),strDetFilePath);
if ~isempty(bbox)
bbox = [bbox(:,1) bbox(:,2) bbox(:,3)-bbox(:,1)+1 bbox(:,4)-bbox(:,2)+1 bbox(:,5:end)];
%idx  = min(size(bbox,1),200);
%bbox = bbox(1:idx, :); 
draw = bbApply('embed',im, bbox,'col',[255 0 0],'lw',2);
imwrite(draw,strDetFilePath);
else imwrite(im,strDetFilePath);
end 
% disp('bounding boxes');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %write boxes to file, before writing we need to resize the image
% if nargin > 2
%    imsz = size(im);
%    % resize so that the image is 300 pixels per inch
%   scale = 1.2 / (imsz(1)/300);
%   im = imresize(im, scale, 'method', 'cubic');
%   sized_box = (bbox-1)*scale+1;  
% end
% bbs = sized_box;

bbs = bbox;

