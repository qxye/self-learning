%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input parameter: n: number of mixture models
%output pameters: model: a DPM model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function model = plane_train(n, max_pos,maxneg, cachesize,note)

%default parameters
if(nargin <1) n   = 3;max_pos= 300; maxneg = 500;cachesize = 5000;  note = '';end
if(nargin <2) max_pos= 300; maxneg = 500;cachesize = 5000;note = '';end
if(nargin <3) maxneg = 500;cachesize = 5000;note = '';end
if(nargin <4) cachesize = 5000;note = '';end
if nargin <5  note = ''; end

initrand();

%����ȫ�ֱ���
globals; 

%����ѵ������
[pos, neg] = plane_data(false,max_pos); 

%2015.1.21  ����������Ϊn�����࣬С����ʱ��ע����С������Ҫ����5��
spos = split(cls, pos, n);     

% model = train(name, model, pos, neg, warp, randneg, iter,
%               negiter, maxsize, keepsv, overlap, cont, C, J)
% Train LSVM.
%
% warp=1 uses warped positives
% warp=0 uses latent positives
% randneg=1 uses random negaties
% randneg=0 uses hard negatives
% iter is the number of training iterations
% negiter is the number of data-mining steps within each training iteration
% maxnum is the maximum number of negative examples to put in the training data file
% keepsv=true keeps support vectors between iterations
% overlap is the minimum overlap in latent positive search
% cont=true we restart training from a previous run
% C & J are the parameters for LSVM objective function
%
% eg:   models{i} = train(cls, models{i},spos{i}(inds), neg, 1, 1, 1, 1, ...
%                     cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);
% train root filters using warped positives & random negatives
%ʹ����������������ķ�������һ����������
try
  load([cachedir cls '_lrsplit1']);
catch
  initrand();
  for i = 1:n
    % split data into two groups: left vs. right facing instances
%     models{i} = initmodel(cls, spos{i}, note, 'N');
%     inds = lrsplit(models{i}, spos{i}, i);%����������������
%     models{i} = train(cls, models{i}, spos{i}(inds), neg, i, 1, 1, 1, ...
%                       cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);

    models{i} = initmodel(cls, spos{i}, note, 'N');
    inds = lrsplit(models{i}, spos{i}, i);%����������������
    models{i} = train(cls, models{i},spos{i}(inds), neg, 1, 1, 1, 1, ...
                      cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);

  end
  save([cachedir cls '_lrsplit1'], 'models');
end

% train root left vs. right facing root filters using latent detections
% and hard negatives
%ʹ�����ؼ����������ѵ�����Ҹ�������

try
  load([cachedir cls '_lrsplit2']);
catch
  initrand();
  for i = 1:n
     models{i} = lrmodel(models{i});
%     models{i} = train(cls, models{i}, spos{i}, neg, 0, 0, 4, 3, ...
%                       cachesize, true, 0.7, false, ['lrsplit2_' num2str(i)]);
                   models{i} = train(cls, models{i}, spos{i}, neg, 0, 0, 4, 3, ...
                      cachesize, true, 0.7, false, ['lrsplit2_' num2str(i)]);
  end
  save([cachedir cls '_lrsplit2'], 'models');
end

% merge models and train using latent detections & hard negatives
%ʹ�����ؼ��������ϲ���ѵ��ģ��
try 
  load([cachedir cls '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(cls, model, pos, neg, 0, 0, 1, 1, ...
                cachesize, true, 0.7, false, 'mix');
            %  model = train(cls, model, pos, neg(1:maxneg), 0, 0, 1, 1, ...
            %    cachesize, true, 0.7, false, 'mix');
  save([cachedir cls '_mix'], 'model');
end

% add parts and update models using latent detections & hard negatives.
%ʹ�����ؼ���������Ӳ����͸���ģ��
try 
  load([cachedir cls '_parts']);
catch
  initrand();
  for i = 1:2:2*n
    model = model_addparts(model, model.start, i, i, 6, [6 6]);
  end
  model = train(cls, model, pos, neg, 0, 0, 4, 3, ...
                cachesize, true, 0.7, false, 'parts_1');
%model = train(cls, model, pos, neg(1:maxneg), 0, 0, 4, 3, ...
%                cachesize, true, 0.7, false, 'parts_1');
  model = train(cls, model, pos, neg, 0, 0, 1, 5, ...
                cachesize, true, 0.7, true, 'parts_2');
%  model = train(cls, model, pos, neg, 0, 0, 1, 5, ...
%                cachesize, true, 0.7, true, 'parts_2');
  save([cachedir cls '_parts'], 'model');
end

save([cachedir cls '_final'], 'model');

%����ģ��֮�����Bboxpred_train
myBboxpred_train();

% load and display modelģ�Ϳ��ӻ�
visualizemodel(model, 1:2:length(model.rules{model.start}));
