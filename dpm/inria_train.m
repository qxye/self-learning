function model = inria_train(n)
%cls = 'inria\';
cls = 'plane\';
n   = 5;  %n要与split.m里的分类数目一致
note='';
% model = pascal_train(cls, n, note)
% Train a model with 2*n components using the PASCAL dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)

% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();

if nargin < 3
  note = '';
end

globals; 
[pos, neg] = inria_data();  %打开数据
% split data by aspect ratio into n groups

spos = split(cls, pos, n);     %2014.12.3  将正样本分为n类，小样本时候注意最小分类数要大于5个
%spos=pos;
%cachesize = 24000;
cachesize = 5000;
maxneg = 500;

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

% train root filters using warped positives & random negatives
%使用弯曲正例及随机的反例创建一个根过滤器
try
  load([cachedir cls '_lrsplit1']);
catch
  initrand();
  for i = 1:n
    % split data into two groups: left vs. right facing instances
%     models{i} = initmodel(cls, spos{i}, note, 'N');
%     inds = lrsplit(models{i}, spos{i}, i);%将正例镜像左右面
%     models{i} = train(cls, models{i}, spos{i}(inds), neg, i, 1, 1, 1, ...
%                       cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);

    models{i} = initmodel(cls, spos{i}, note, 'N');
    inds = lrsplit(models{i}, spos{i}, i);%将正例镜像左右面
    models{i} = train(cls, models{i},spos{i}(inds), neg, i, 1, 1, 1, ...
                      cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);


  end
  save([cachedir cls '_lrsplit1'], 'models');
end

% train root left vs. right facing root filters using latent detections
% and hard negatives
%使用隐藏检测器和难例训练左右根过滤器

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
%使用隐藏检测和难例合并和训练模型
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
%使用隐藏检测和难例添加部件和更新模型
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



