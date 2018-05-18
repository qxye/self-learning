function video = st_frames6Video
%函数功能：把保存在framesPath文件夹下的所有‘jpg’格式的图像转换为‘avi’格式的视频
    %framesPath :图像序列所在路径，同时要保证图像大小相同。
    %            图像格式在程序中设置的是 'jpg'格式！！
    %videoName:  表示将要创建的视频文件的名字
    %fps: 帧率
    %startFrame ,endFrame ;表示从哪一帧开始，哪一帧结束
%     
%     framesPath = 'D:\sceneExperiment\scene\Dataset\scene8\image\MITcoast';   
%     videoName = 'test.avi';  
%     fps = 7;    

    framesPath = '.\data\PETS09-S2L2\detect'
    
    imageList = dir(fullfile('.\data\PETS09-S2L2\detect', '*.jpg'));
    allImgList = dir(fullfile( '.\data\PETS09-S2L2\pos', '*.png'));        

    %remove the existing image file
    if(exist('videoName','file'))
        delete videoName.avi
    end

    %生成视频的参数设定
    video = VideoWriter('demo.avi');  %创建一个avi视频文件对象，开始时其为空
    video.FrameRate = 10;   
    open(video);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:10
          srcName = ['1.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
    end
     for i=1:10
          srcName = ['2.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
     end
    
     framesPath = '.\data\PETS09-S2L2\pos'
      
      for i=1:3:217
          srcName = [framesPath '\' num2str(i) '.png'];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:10
          srcName = ['3.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
    
      for i=1:3:217
          srcName = [framesPath '\' num2str(i) '_diff.png'];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
      end
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:10
          srcName = ['4.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
    
      for i=1:3:217
          srcName = [framesPath '\' num2str(i) '_1.png'];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:10
          srcName = ['5.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
    
      for i=1:3:217
          srcName = [framesPath '\' num2str(i) '_2.png'];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
      end               
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:10
          srcName = ['6.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
    
      for i=1:3:217
          srcName = [framesPath '\' num2str(i) '_9.png'];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
      end              
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:10
          srcName = ['7.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
    
             
   %final detections
   framesPath = '.\data\PETS09-S2L2\detect'
   
         for i=218:size(imageList,1)
          srcName = [framesPath '\' imageList(i).name];
             ImgSrc = imread(srcName);
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
         end
         
         for i=1:10
          srcName = ['8.png'];
             ImgSrc = imread(srcName);
             ImgSrc(ImgSrc>0) = 200;
             ImgSrc = imresize(ImgSrc,[432 576]);
             disp(i);
             writeVideo(video, ImgSrc);
        end
        
close(video);