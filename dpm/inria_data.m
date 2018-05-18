function [pos, neg] = input_data(flippedpos)

year = '2015';
globals

if nargin < 1  flippedpos = false; end
% should the tmpdir be cleaned after training a model?
cleantmpdir = true; 

%初始化参数
pos = []; numpos = 0;  best_data=[];
x1 = 0;  x2 = 0;  y1 = 0;  y2 = 0;

%读入训练样本
fid=fopen(poslist,'r');
i = 1; index =1;

%到文件末尾返回假值   
while ~feof(fid)  
    posfile =fgetl(fid);
    posfile =[posdir posfile];%正样本的路径\文件名
    if ~ischar(posfile),....
        break;
    end    
    %自加的数量限制        
    %if numpos>100, break; end    
    annfile = strrep(posfile,'.png','.txt');  
    % strrep将posfile中的png替换成txt
    
    %读入标记
    fann=fopen(annfile,'r');   
    if(fann<=0 ) 
        ('open file faied!');
        continue;
    end
  
    while(~feof(fann))
        Y = fscanf(fann,'%f %f %f %f %f',13); 
        X=[Y(10),Y(10)+Y(12) Y(11) Y(11)+Y(13) Y(9)];
        if size(Y)<13,break;      
    end 
                
    numpos = numpos+1;        
    %读取正例数据结构
    pos(numpos).im = posfile;   %图片名字
    pos(numpos).x1 = X(1);   pos(numpos).x2 = X(2);
    pos(numpos).y1 = X(3);   pos(numpos).y2 = X(4);
    pos(numpos).trunc = 0;  
    pos(numpos).theta=X(5);%角度
    pos(numpos).flip  = flippedpos; 
    end   
    
    fclose(fann); 
    i = i+1;
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(neglist,'r');
numneg = 0;
while ~feof(fid)
    negfile =fgetl(fid);
    negfile =[negdir negfile];%负样本的路径\文件名
    if ~ischar(negfile),break;end      
      numneg = numneg+1;
      neg(numneg).im = negfile;
      neg(numneg).flip = false;  
end
fclose(fid);

save([cachedir cls '_train_' year], 'pos', 'neg');  %存到模型路径


