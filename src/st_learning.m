%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is a matlab code for self-learning pedestrian detectors in videos
%Qixiang Ye, , 2015, University of Chinese Academy of Sciences
%
%This software is free for academic research purpose.
%input: strVideoName: full name of the input video
%output: learned pedestrian detectors in the model folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function st_learning(strVideoName)
%tesing the input video file
if ~exist(strVideoName) disp('Do not find the input video file');end
strPath = strrep(strVideoName,'.avi','');

%learning parameter setting
paras = st_paras_setting;

%setting a global path for DPM data
global global_path;      %global path setting for DPM learning
global g_temploral_flag; %global path setting for temporal data
global_path = [strPath];
if ~exist(global_path) disp('Do not find the global path for input video data');end

%% background modeling
[aviPlayer sumFrame numFrames step] = bgModeling(strVideoName, paras);

%% generate files and folders
generateFolders(strPath);

%% incremental learning 
w  = [1.2;1.2;1.0]; w = w/sum(w);  %initiate of learning weights
w0 = [1.2;1.2;1.0]; w0 = w0/sum(w0);  
userDetector = 0;
%initilize the graph sample features
graphFea   = []; graphLabel = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initilization:learning temporal latentModel
for r = 1:2 
     %detecting spatial-temporal proposals
    pos_fea_bags = {}; neg_fea_bags = {};
    for i=1:step:numFrames               
        disp(['r=' num2str(r) ' i=' num2str(i)]);
        %moving detection
        frame = read(aviPlayer, i);    
        frame = imresize(frame, paras.scale); 
        %calculating the frame difference
        diffImage  =  abs(sumFrame - double(frame));        
        %sumarizing multiple channels
        if(size(diffImage,3)>1)fgMask = sum(diffImage,3)/3; else fgMask = diffImage; end          
        %foreground detection   %figure(3),imshow(uint8(fgMask));                        
        if(r ==1) %first learning iteartion
         %generate spatial temporal proposals
         [all_bbs,pos_bbs, neg_bbs]  = st_edgeBoxesRank(frame,diffImage,fgMask,paras,w0);                                  
        else
         [all_bbs,pos_bbs, neg_bbs]  = st_edgeBoxesRank(frame,diffImage,fgMask,paras,w0,latentW);                                                
        end
        
        %writting out the heatMap
        %heat_path = [strPath, '/heat']; if ~exist(heat_path) mkdir(heat_path); end
        %st_heatMap(size(frame),all_bbs,heat_path,[num2str(r) '-' num2str(i)]);        
        %WriteImagesAndBBs(frame,frame,diffImage,all_bbs,pos_bbs,neg_bbs,r,i,i+paras.T,strPath);
        pos_fea_bags{end+1} = st_featBag(frame,pos_bbs);
        neg_fea_bags{end+1} = st_featBag(frame,neg_bbs);        
    end     
    
  %Latent disriminaitve learning given pos and neg features from all frames  
  [latentW] = st_latentSVMLearning(pos_fea_bags, neg_fea_bags);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Fine turning:learning temporal latentModel
for r =1:paras.EM_iter     
    all_pos_bbs      = [];    
    g_temploral_flag =  0;       
    paras.bbs_num    = uint16(paras.bbs_num*paras.learn_rate+1);      
  %reranking spatial-temporal proposals
  for i=1:step:numFrames       
       
       disp(['r=' num2str(r) ' i=' num2str(i)]);

        %reading one frame
        frame = read(aviPlayer, i);    
        frame = imresize(frame, paras.scale); 
        %calculating the frame difference
        diffImage  =  abs(sumFrame - double(frame));        
        %sumarizing multiple channels
        if(size(diffImage,3)>1)fgMask = sum(diffImage,3)/3; else fgMask = diffImage; end                
        %foreground detection,  %figure(3),imshow(uint8(fgMask));                
        pos_path    = [strPath, '/pos'];
        file_name   = [num2str(i) '.png'];
        frame_file  = [pos_path '/' num2str(i) '.png'];
        det_file    = [pos_path '/' num2str(i) '_' num2str(r) '_det.png'];        
        tracked_path= [strPath, '/tracked_pos']; 
        tracked_det_file    = [tracked_path '/' num2str(i) '_' num2str(r) '_det.png'];         
        
        if(r ==1) %first learning iteartion
         %generate spatial temporal proposals
         [all_bbs neg_bbs rank_bbs]  = st_detectBoxesRank(frame,diffImage,fgMask,paras,w,latentW);              
         pos_bbs    = rank_bbs;  tracked_bbs= rank_bbs;  
         end_frame = i+paras.T; end_frame = min(end_frame,numFrames);
         tracked_frame = read(aviPlayer, end_frame); tracked_frame = imresize(tracked_frame, paras.scale);                      
         %updating the graph
         [graphFea,graphLabel] = updateGraph(frame, pos_bbs, neg_bbs,graphFea,graphLabel);     
         else %other iterations         
          %detecting new proposals using learned DPM, using very strict nms
          disp('Detecting...');
          bbs_dpm = st_dpm_detect_img(frame,paras.det_thre-1.0,0.75,det_file);                    
          %ranking using combined values
          disp('Rankinging...');
          [all_bbs neg_bbs rank_bbs]  = st_detectBoxesRank(frame,diffImage,fgMask,paras,w,latentW,bbs_dpm,paras.nms_thre);                                                                 
          xU = st_fea2scales(frame, rank_bbs);                                     
          %classifying the high ranked bbs
          disp('Classifying...');
          pos_bbs      = st_detectBoxesClassify(rank_bbs,paras.det_thre,graphFea,graphLabel,xU);                                      
          %tracking the detected bbs in the following T frames, classify            
          disp('Trackinging...');
          [tracked_boxes tracked_frame] = Tracking(aviPlayer,numFrames,i,i+paras.T,pos_bbs,paras.scale);           
          xU     = st_fea2scales(tracked_frame, tracked_boxes);   
          disp('Classifying...');
          tracked_bbs = st_detectBoxesClassify(tracked_boxes,paras.det_thre+0.1,graphFea,graphLabel,xU);                              
          %update the graph
          [graphFea,graphLabel] = updateGraph(frame, pos_bbs, neg_bbs,graphFea,graphLabel);        
          all_pos_bbs = [all_pos_bbs;pos_bbs];        
        end 
        
        %writting out the heatMap
        if(i ==1) figure; end
        heat_path = [strPath, '/heat']; if ~exist(heat_path) mkdir(heat_path); end
        st_heatMap(r, size(frame),all_bbs,heat_path,[num2str(r) '-' num2str(i)]);
        
       %% writting out bbs
        WriteImagesAndBBs(frame,tracked_frame,diffImage,all_bbs,pos_bbs,tracked_bbs, r,i,i+paras.T,strPath);                                 
    end      
    
    %moving the old models of previous iterations
    model_dir   = [global_path '\model'];
    model_files = [model_dir '\*.mat'];
    targt_dir   = [model_dir '\' num2str(r)]; 
    mkdir(targt_dir);
    if(length(dir([model_dir '\*.mat']))>0) movefile(model_files, targt_dir); end
         
    %calculating the ranking weights using a self-adpative learning
    if(r>1) 
    disp('evaluating the weights...');
    w = st_learningWeight(all_pos_bbs); w =full(w); bugs here
    w = w0'.*w; w = w/sum(w); w0= w0.*sqrt(w0);       
    %w = w0.*w; w = w/sum(w); w0= w0.*sqrt(w0); 
    weight_file  = [strPath '\model\weight.txt'];
    file = fopen(weight_file,'a+');
    fprintf(file, '%f %f %f\n', w(1), w(2), w(3));    
    fclose(file);    
    end      
   
    %training detectors with DPM
    g_temploral_flag =0;
    if(r< paras.EM_iter)    st_dpm_train(1);    st_dpm_train(1);    
    %the last learning iteration, uisng mixture models of DPM
    else                    st_dpm_train(3);    st_dpm_train(3);
    end
    
    userDetector = 1;
end%for
clear 

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%writting out of positive images with ranked bbs
%r is the iteration of tracking, i is the index of frame, tracked_i is the
%the frame index for tracked object
function WriteImagesAndBBs(frame,tracked_frame,diffImage,all_bbs,pos_bbs,tracked_bbs,r,i,tracked_i,path)

%making a director for pos images and tracked pos images
pos_path = [path, '/pos'];
if ~exist(pos_path) mkdir(pos_path); end
tracked_path = [path, '/tracked_pos'];
if ~exist(tracked_path) mkdir(tracked_path); end

%copying the rectange and scores
bbs = [pos_bbs(:,1:4) pos_bbs(:,8) pos_bbs(:,5:7)];

%frame image and other file name to be inserted into pos image list file
file_name       = [num2str(i) '.png'];
frame_file      = [pos_path '/' num2str(i) '.png'];
frame_bbs_file  = [pos_path '/' num2str(i) '_' num2str(r) '.png'];
diff_file       = [pos_path '/' num2str(i) '_diff.png'];
bbs_file        = [pos_path '/' num2str(i) '.txt'];

%tracked frame name and other informations
tracked_file_name       = [num2str(tracked_i) '.png'];
tracked_frame_file      = [tracked_path '/' num2str(tracked_i) '.png'];
tracked_frame_bbs_file  = [tracked_path '/' num2str(tracked_i) '_' num2str(r) '.png'];
tracked_bbs_file        = [tracked_path '/' num2str(tracked_i) '.txt'];

%drawing current bbs
if size(bbs,1)>0
    if(r==1)
        tmp_bbs =all_bbs(:,1:4); 
        tmp_frame  = bbApply('embed', frame, tmp_bbs,'col',[0 255 0], 'lw',2); 
        frame_with_bbs  = bbApply('embed', tmp_frame, bbs,'col',[255 0 0], 'lw',2); 
    else
    frame_with_bbs  = bbApply('embed', frame, bbs,'col',[255 0 0], 'lw',2); 
    end
else  frame_with_bbs = frame;  
end

if size(tracked_bbs,1) >0    
    tracked_frame_with_bbs = bbApply('embed', tracked_frame, tracked_bbs,'col',[255 255 0]);     
else
    tracked_frame_with_bbs = tracked_frame;
end

%write out images
if(r ==1) imwrite(frame,frame_file);end
if(r ==1) imwrite(tracked_frame,tracked_frame_file);  end
if(r ==1) imwrite(uint8(diffImage),diff_file);end
imwrite(frame_with_bbs,frame_bbs_file);
if ~isempty(tracked_frame_with_bbs) imwrite(tracked_frame_with_bbs,tracked_frame_bbs_file); end

%writting positive file list
if(r ==1)
pos_image_list_path = [path '/pos_filelist.txt'];
file = fopen(pos_image_list_path,'a+');
%if ~exist(pos_image_list_path) file = fopen(pos_image_list_path,'w+');end
fprintf(file, '%s\n', file_name);  
fclose(file);
end

%writting tracked positive file list
%noting that tracked proposals should be merged with spatial proposals
if(r==1)
tracked_image_list_path = [path '/tracked_filelist.txt'];
file = fopen(tracked_image_list_path,'a+');
fprintf(file, '%s\n', tracked_file_name);  
fclose(file);
end

if(r>1)
%from the second iteration,merging tracked bbs with positive bbs
pos_image_list_path = [path '/pos_filelist.txt'];
file = fopen(pos_image_list_path,'a+');
fprintf(file, '%s\n', tracked_file_name);  
fclose(file);
end

%write out bbs
if(r<=1) file = fopen(bbs_file,'w+'); 
else     file = fopen(bbs_file,'a+'); 
end

for m=1:size(bbs,1)
fprintf(file, '%f %f %f %f %f %f %f %f\n',...
    bbs(m,1), bbs(m,2), bbs(m,3),bbs(m,4),bbs(m,5),bbs(m,6),bbs(m,7),bbs(m,8));
end
fclose(file);

%write out tracked bbs
if(r<=1) file = fopen(tracked_bbs_file,'w+');
else     file = fopen(tracked_bbs_file,'a+');
end

for m=1:size(tracked_bbs,1)
fprintf(file, '%f %f %f %f %f %f %f %f\n',...
    tracked_bbs(m,1), tracked_bbs(m,2), tracked_bbs(m,3),tracked_bbs(m,4),...
    tracked_bbs(m,5),tracked_bbs(m,6),tracked_bbs(m,7),tracked_bbs(m,8));
end
fclose(file);

% %copying tracked files into pos directory
if(r>1)
copyfile(tracked_frame_file, pos_path);
copyfile(tracked_bbs_file, pos_path);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [graphFea, graphLabel] = updateGraph(frame, pos_bbs, neg_bbs,graph_fea,graphLabel)

  %extract features and updating the graph  neg_fea = st_fea2scales(frame, neg_bbs);
  pos_fea       = st_fea2scales(frame, pos_bbs);                
  neg_fea       = st_fea2scales(frame, neg_bbs);    
  num           = min(size(pos_fea,1),2);
  graphFea      = [graph_fea;pos_fea(num,:);neg_fea(num,:)]; 
  graphLabel    = [graphLabel; ones(size(num,1),1);-ones(size(num,1),1)];
end

%% BackgroundModeling:calculating video background frame
function [aviPlayer sumFrame numFrames step] = bgModeling(strVideoName, paras)
aviPlayer = VideoReader(strVideoName);
numFrames = get(aviPlayer, 'NumberOfFrames')/2; % use half for learning
step = uint32(numFrames/paras.numBgFrames);
sumFrame = 0;
for i=1:step:numFrames    
    frame = read(aviPlayer, i); 
    frame = imresize(frame, paras.scale);  
    
    if(i==1)  sumFrame = double(frame); 
    else sumFrame = sumFrame+double(frame); end        
    fprintf('background modeling.. the %d th frame\n',i);    
end
sumFrame = sumFrame/double(uint32(numFrames/step));
end

function generateFolders(strPath) 

if 0~=mkdir(strPath) disp('creating data folder fails'); end;
if 0~=mkdir([strPath '/model']) disp('creating data folder fails'); end;
if 0~=mkdir([strPath '/pos']) disp('creating positive data folder fails'); end;
if 0~=mkdir([strPath '/tracked_pos']) disp('creating tracking data folder fails'); end;
if 0~=mkdir([strPath '/neg']) disp('creating negative data folder fails'); end;
pos_list_file  = [strPath '\pos_filelist.txt']
tracked_image_list_path = [strPath '\tracked_filelist.txt'];

%clear the poslist file
delete(pos_list_file);
delete(tracked_image_list_path);
end