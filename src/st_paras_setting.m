function [paras] =  st_paras_setting

%parameter setting
paras.numBgFrames  = 50 ; %number of frames for learning
%paras.maxFrames    = 1000; %maxium number of frames for learning
paras.EM_iter      = 6    ; %learning iterations
paras.bgThreshold  = 0.2  ; %background modeling threshold
paras.ratio_min    = 2.0 ; %min height/width ratio of proposals
paras.ratio_max    = 8.0 ; %max height/width ratio of proposals 
paras.size_min     = 0.1; %min size ratio to image size
paras.size_max     = 0.5; %max size ratio to image size
paras.scale        = 1.5 ; %scale the video frame size
paras.bbs_num      = 3   ; %initial bbs number
paras.learn_rate   = 1.5; %learning rate
paras.det_thre     = 0.0 ; %dpm detection threshold
paras.nms_thre     = 0.5 ; %dpm nms threshold 
paras.T            = 10;   %temporal frames for tracking

end