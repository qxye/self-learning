function [pos, neg] = input_data(flippedpos)

year = '2015';
globals

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
    if ~ischar(posfile),....
        break;
    end    
    %�Լӵ���������        
    %if numpos>100, break; end    
    annfile = strrep(posfile,'.png','.txt');  
    % strrep��posfile�е�png�滻��txt
    
    %������
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
    %��ȡ�������ݽṹ
    pos(numpos).im = posfile;   %ͼƬ����
    pos(numpos).x1 = X(1);   pos(numpos).x2 = X(2);
    pos(numpos).y1 = X(3);   pos(numpos).y2 = X(4);
    pos(numpos).trunc = 0;  
    pos(numpos).theta=X(5);%�Ƕ�
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
    negfile =[negdir negfile];%��������·��\�ļ���
    if ~ischar(negfile),break;end      
      numneg = numneg+1;
      neg(numneg).im = negfile;
      neg(numneg).flip = false;  
end
fclose(fid);

save([cachedir cls '_train_' year], 'pos', 'neg');  %�浽ģ��·��


