function video = st_frames6Video
%�������ܣ��ѱ�����framesPath�ļ����µ����С�jpg����ʽ��ͼ��ת��Ϊ��avi����ʽ����Ƶ
    %framesPath :ͼ����������·����ͬʱҪ��֤ͼ���С��ͬ��
    %            ͼ���ʽ�ڳ��������õ��� 'jpg'��ʽ����
    %videoName:  ��ʾ��Ҫ��������Ƶ�ļ�������
    %fps: ֡��
    %startFrame ,endFrame ;��ʾ����һ֡��ʼ����һ֡����
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

    %������Ƶ�Ĳ����趨
    video = VideoWriter('demo.avi');  %����һ��avi��Ƶ�ļ����󣬿�ʼʱ��Ϊ��
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