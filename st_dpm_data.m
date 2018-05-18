function [pos, neg] = st_dpm_data(flippedpos,max_pos_num)

year = '2015';

global g_temploral_flag;
if g_temploral_flag
globals_temporal;
else
globals;
end

if nargin < 1  flippedpos = false; end
% should the tmpdir be cleaned after training a model?
cleantmpdir = true; 

%��ʼ������
pos = []; numpos = 0;  best_data=[];
x1 = 0;  x2 = 0;  y1 = 0;  y2 = 0;

%����ѵ������
fid=fopen(poslist,'r');
i = 1; index =1;

%���ļ�ĩβ���ؼ�ֵ   
while ~feof(fid)  
    
    posfile =fgetl(fid);
    posfile =[posdir posfile];%��������·��\�ļ���
    
    if ~ischar(posfile) continue;  end    
    
    %�Լӵ���������        
    if (nargin >=2 & numpos>max_pos_num) break; end    
    
    annfile = strrep(posfile,'.png','.txt');  
        
    %������Ŀ����Ϣ
    fann=fopen(annfile,'r');   
    if(fann<=0 ) ('open file faied!'); continue;  end
  
    while(~feof(fann))
        Y = fscanf(fann,'%f %f %f %f %f',8); 
        if size(Y)<8,continue;end                         
        X=[Y(1), Y(1)+Y(3), Y(2), Y(2)+Y(4) Y(8)];                
        
        numpos = numpos+1;        
        %��ȡ�������ݽṹ
        pos(numpos).im = posfile;   %ͼƬ����
        pos(numpos).x1 = X(1);   pos(numpos).x2 = X(2);
        pos(numpos).y1 = X(3);   pos(numpos).y2 = X(4);
        pos(numpos).trunc = 0;  
        pos(numpos).theta=X(5);%�ܵ÷�
        pos(numpos).flip  = flippedpos; 
    end   
    
    fclose(fann); 
    i = i+1;
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(neglist,'r');
numneg = 0;
while ~feof(fid)
    negfile =fgetl(fid);
    negfile =[negdir negfile];%��������·��\�ļ���
    if ~ischar(negfile),break;end      
      numneg = numneg+1;
      neg(numneg).im = negfile;
      neg(numneg).flip = false;  
end
fclose(fid);

save([cachedir cls '_train_' year], 'pos', 'neg');  %�浽ģ��·��


