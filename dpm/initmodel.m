function model = initmodel(cls, pos, note, symmetry, sbin, sz)

% model = initmodel(cls, pos, note, symmetry, sbin, sz)
% Initialize model structure.
%
% If not supplied the dimensions of the model template are computed
% from statistics in the postive examples.

% pick mode of aspect ratios
%选择模式方面的比率
h = [pos(:).y2]' - [pos(:).y1]' + 1;
w = [pos(:).x2]' - [pos(:).x1]' + 1;
xx = -2:.02:2;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%6.20
filter = exp(-[-100:100].^2/400);
temp = log(h./w);
aspects = hist(log(h./w), xx);
%n = hist(Y, x)
%x是一个向量，返回x的长度个以x为中心的，Y的分布情况。
%例如：如果x是一个5元素的向量，返回Y在以x为中心的，x长度个范围内数据直方分布。
aspects = convn(aspects, filter, 'same');
%C = convn(A,B,'shape') returns a subsection of the N-dimensional convolution, as specified by the shape parameter:
%'same'Returns the central part of the result that is the same size as A.
%过滤器与图像卷积计算积分
[peak, I] = max(aspects);
%[C,I]=max(a);C表示的是矩阵a每列的最大值，I表示的是每个最大值对应的下标
aspect = exp(xx(I));

% pick 20 percentile area
%选择20百分位区域
areas = sort(h.*w);
%升序排列
area = areas(floor(length(areas) * 0.2));
%floor(x):不超过x的最大整数.(高斯取整)?
area = max(min(area, 5000), 3000);
%设置上下限

% pick dimensions
w = sqrt(area/aspect);
h = w*aspect;

if nargin < 3
  note = '';
end

% get an empty model
model = model_create(cls, note);
model.interval = 10;

if nargin < 4
  symmetry = 'N';
end

% size of HOG features
if nargin < 5
  model.sbin = 8;
else
  model.sbin = sbin;
end

% size of root filter
if nargin < 6
  sz = [round(h/model.sbin) round(w/model.sbin)];
end

% add root filter
[model, symbol, filter] = model_addfilter(model, zeros([sz 32]), symmetry);

% start non-terminal
[model, Q] = model_addnonterminal(model);
model.start = Q;

% add structure rule deriving only a root filter placement
%添加结构规则中只有一个根过滤放置
model = model_addrule(model, 'S', Q, symbol, 0, {[0 0 0]});
% Add a rule to the model.
% [m, offsetbl, defbl] = model_addrule(m, type, lhs, rhs, offset, ...
%                                              params, symmetric, offsetbl, defbl)
% m          object model
% type       'D'eformation or 'S'tructural
% lhs        left hand side rule symbol
% rhs        right hand side rule symbols
% offset     production score
% params     anchor position for structural rules
%            deformation model for deformation rules
% symmetric  'N'one or 'M'irrored
% offsetbl   block for offset
% defbl      block for deformation model

% set detection window
model = model_setdetwindow(model, Q, 1, sz);
