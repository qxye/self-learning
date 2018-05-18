% Set up global variables used throughout the code
% setup svm mex for context rescoring (if it's installed)
if exist('.\svm_mex601') > 0
  addpath svm_mex601\bin;
  addpath svm_mex601\matlab;
end

% dataset to use
if exist('setVOCyear') == 1
  VOCyear = setVOCyear;
  clear('setVOCyear');
else
  VOCyear = '2015';
end

% directory for caching models, intermediate data, and results
cachedir = ['voc' VOCyear '\'];

if exist(cachedir) == 0
  dos(['mkdir ' cachedir]);  %������Ϊcachedir����Ŀ¼
  if exist([cachedir 'learnlog\']) == 0
    dos(['mkdir ' cachedir 'learnlog\']);
  end
end

% directory for LARGE temporary files created during training
tmpdir = ['voc' VOCyear '\'];

if exist(tmpdir) == 0
  dos(['mkdir ' tmpdir]);
end

% should the tmpdir be cleaned after training a model?
cleantmpdir = true;

% directory with PASCAL VOC development kit and dataset
VOCdevkit = ['VOCdevkit'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for plane training 
tmpdir   = 'plane\tmp\';
cachedir = 'plane\model\'; %ѵ��ʱģ�����ɵ�λ��
poslist  = 'plane\pos_filelist.txt';%ѵ�������������ļ����б�
neglist  = 'plane\neg_filelist.txt';
posdir   = 'plane\pos\';
negdir   = 'plane\neg\';

if exist(cachedir) == 0
  dos(['mkdir ' cachedir]);  %������Ϊcachedir����Ŀ¼
end

%testmodel = 'Plane\train\model\rotmodelFrom400Pos\plane_final';
testmodel = 'Plane\model\plane_final';
testdir = 'Plane\Pos\';
testlist= 'Plane\test_filelist.txt';

cls = 'plane';
year = '2015';
name = 'plane'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%