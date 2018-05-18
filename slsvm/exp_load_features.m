function [feat,labels, boxes, im_ids] = exp_load_features(slsvm_path, id_label_file, train_or_test)
% exp_load_features load voc2007 features
%           D: feature dimensionality (4096 in the paper)
%           N: number of images
%         nbi: number of bounding boxes in image i
%        feat: 1xN cell
%   feat(i).x: Dxnbi "single" matrix for image i

imdb_path     = [slsvm_path.dataset_path, 'VOCdevkit/VOC2007/ImageSets/Main/']; % id and label

fid  = fopen([imdb_path, id_label_file]);
imdb = textscan(fid, '%s %d');
fclose(fid);

set_name = id_label_file(1:end-13);

% train postive
im_ids_pos = imdb{1}(imdb{2} == 1);  % postive index
im_ids_neg = imdb{1}(imdb{2} == -1); % negtive index
n_pos      = length(im_ids_pos);
n_neg      = length(im_ids_neg);
idx        = randperm(n_neg);
im_ids_neg = im_ids_neg(idx(:)); % true part of the neg images

% im_ids = im_ids_pos; feat = [];boxes = [];gt = [];labels = [];

if strcmp(train_or_test, 'train')
    n_pos  = min(n_pos, 700);
    n_neg  = min(n_pos, 200);
    im_ids = [im_ids_pos(1:n_pos); im_ids_neg(1:n_neg)];
    labels = [ones(1, n_pos), -1*ones(1, n_neg)];
    feat_path = slsvm_path.feat_train_path;
else
    im_ids = im_ids_pos;
    labels = ones(1, length(im_ids));
    feat_path = slsvm_path.feat_test_path;
end

n_img = length(im_ids);
feat  = struct([]);
boxes = cell(1, n_img);

for i = 1:n_img
    matfile_path = [feat_path, im_ids{i}, '.mat'];
    d = load(matfile_path);
    d.feat  = d.feat(d.gt~=1, :); % delete groundtruth training sample
    d.boxes = d.boxes(d.gt~=1, :);
    add_last_bin = ones(size(d.feat, 1), 1);
    feat(i).x = [d.feat, add_last_bin]';
    boxes{i}  = d.boxes;
    tic_toc_print('%s -- perparing data %d/%d\n', set_name, i, n_img);
end
