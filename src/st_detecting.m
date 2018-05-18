%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is a matlab based foreground modeling code developed by
%Qixiang Ye, Jan, 2015, University of Chinese Academy of Sciences
%
%This software is free for academic research purpose, but not commercial purpose.
%parameters
%
%strVideoName: full name of the input video
%paras.numBgFrames:  number of frames for background modeling;
%paras.bgThreshold  = threshold for background modeling;;
%paras.ShowFg       = flag to indicate wehther to show foreground pixels;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function st_detecting(strVideoName, paras)

%tesing the input video file
if ~exist(strVideoName) disp('Do not find the input video file');end
strPath = strrep(strVideoName,'.avi','');

%setting a global path
global global_path;
global_path = [strPath];
if ~exist(global_path) disp('Do not find the global path for input video data');end

if(nargin<3) 
%paras.numBgFrames  = 100;
%paras.vido_step    = 500;
%paras.EM_iter      = 10;
%paras.bgThreshold  = 50;
paras.ShowFg       = 0;
%paras.ratio_min    = 2.0;
%paras.ratio_max    = 100.0;
paras.size_min     = 0.1;
paras.size_max     = 0.5;
paras.bbs_num      = 100;%number of poposals
paras.det_thre     = 0.15;%dpm detection threshold
paras.can_thre     = -0.5;%dpm detection threshold
paras.nms_thre     = 0.5;%dpm nms threshold 
paras.scale        = 1.5;%scale the video frame size
%paras.learn_rate   = 1.25;%learning rate
%paras.T            = 10;% temporal frames for tracking
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edgeBox_model=load('./edges-master/models/forest/modelBsds'); edgeBox_model=edgeBox_model.model;
edgeBox_model.opts.multiscale=0; edgeBox_model.opts.sharpen=2; edgeBox_model.opts.nThreads=4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stucture of the video data
aviPlayer=VideoReader(strVideoName);
%video information
numFrames = get(aviPlayer, 'NumberOfFrames');
% step = uint16(numFrames/paras.numBgFrames);

%background modeling
sumFrame = 0;
for i=1:1:min(numFrames,1000)    
    frame = read(aviPlayer, i); 
    frame = imresize(frame, paras.scale);    
    
    if(i==1)  sumFrame = double(frame); 
    else sumFrame = sumFrame+double(frame); end        
    fprintf('background modeling.. the %d th frame\n',i);    
end
sumFrame = sumFrame/min(numFrames,1000); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate folders for positive
if 0~=mkdir(strPath) disp('creating data folder fails'); end;
if 0~=mkdir([strPath '/detect']) disp('creating data folder fails'); end;

%the positive and tracking list file
detect_list_file  = [strPath '\detect_filelist.txt'];
%clear the poslist file
delete(detect_list_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%detecting all of the frames
w = load([strPath '\model\weight.txt']);
w = w(end,:);
%reloading video data
aviPlayer=VideoReader(strVideoName);

for i=1:1:numFrames      
    
    i
    %reading one frame
    frame = read(aviPlayer, i);    
    frame = imresize(frame, paras.scale);        
        
    %calculating the frame difference
    diffImage  =  abs(sumFrame - double(frame));    
    
    %sumarizing multiple channels
    if(size(diffImage,3)>1)fgMask = sum(diffImage,3)/3; else fgMask = diffImage; end        
    %foreground detection   
    if (paras.ShowFg)  figure(3),imshow(uint8(fgMask)) ; end     
        
    detect_path  = [strPath, '/detect'];
    file_name   = [num2str(i) '.png'];
    det_file  = [detect_path '/' num2str(i) '.png'];

    %detecting candidates using learned detector
    bbs_dpm = st_dpm_detect_img(frame,paras.can_thre,paras.nms_thre,det_file);                            
    
    %ranking using combined values       
   [all_bbs neg_bbs pos_bbs]  = st_detectBoxesRank(uint8(diffImage),edgeBox_model,paras, fgMask,w,bbs_dpm);
  
   top = nms2(pos_bbs, paras.nms_thre);  pos_bbs = pos_bbs(top,:);

   %showing the boxes
   %bbApply( 'draw', bb, [col], [lw], [ls], [prop], [ids] )
   if (paras.ShowFg) figure(3),bbApply('draw',double(pos_bbs)); end    
   %if (paras.ShowFg) figure(3),bbApply('draw',double(neg_bbs),'r',2,'.'); end            
   %for the fisrt round of EM                
   WriteResults(frame,pos_bbs,i,strPath,paras);                                      
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear 
end%function

%writting out of positive images with ranked bbs
%r is the iteration of tracking, i is the index of frame, tracked_i is the
%the frame index for tracked object
function WriteResults(frame,bbs,i,path,paras)

%making a director for pos images and tracked pos images
detect_path = [path, '/detect'];
if ~exist(detect_path) mkdir(detect_path); end

%frame image and other file name to be inserted into pos image list file
file_name   = [num2str(i) '.png'];
name = sprintf('%0.5d',i);
frame_all_bbs_file   = [detect_path '/' num2str(i) '_all.png'];
frame_bbs_file       = [detect_path '/' name '.jpg'];
bbs_file             = [detect_path '/' num2str(i) '.txt'];

%only on bbs file for a video or one image set
%bbs_file             = [detect_path '/dt.txt'];

%drawing all bbs
if size(bbs,1)>0   
frame_with_all_bbs  = bbApply('embed', frame, bbs); 
else  frame_with_all_bbs = frame;  
end

%thresholding results
pos_bbs = st_detectBoxesFinal(bbs,paras.det_thre);  

%drawing postive bbs
if size(bbs,1)>0   
frame_with_bbs  = bbApply('embed', frame, pos_bbs, 'lw',4,'col',[0,0,255]); 
else  frame_with_bbs = frame;  
end

%write out images
imwrite(frame_with_all_bbs,frame_all_bbs_file);
imwrite(frame_with_bbs,frame_bbs_file);

%writting positive file list
detect_image_list_path = [path '/detect_filelist.txt'];
file = fopen(detect_image_list_path,'a');
fprintf(file, '%s\n', file_name);  
fclose(file);

%write out bbs
file = fopen(bbs_file,'w+');
for m=1:size(bbs,1)
fprintf(file, '%f %f %f %f %f %f %f %f\n',...
    bbs(m,1), bbs(m,2), bbs(m,3),bbs(m,4),bbs(m,5),bbs(m,6),bbs(m,7),bbs(m,8));
end
fclose(file);

%detection results formating:  frameindex box_index, x,y,w,h,scores
% persistent box_idx;
% if(i<=1) box_idx =1;
% else box_idx = box_idx +1;
% end
% 
% file = fopen(bbs_file,'a+');
% for m=1:size(bbs,1)
% 
%     %scale back
%     bbs(m,1:4) = bbs(m,1:4)/paras.scale;
%     
% fprintf(file, '%d %d %f %f %f %f %f %f %f %f\n',...
%     i,box_idx,bbs(m,1), bbs(m,2), bbs(m,3),bbs(m,4),bbs(m,5),bbs(m,6),bbs(m,7),bbs(m,8));
% end
% fclose(file);

end
