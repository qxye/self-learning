% -------------------------------------------------------------------------
function ap = compute_average_precision(scores,labels)
% -------------------------------------------------------------------------
if numel(scores)~=numel(labels)
  error('Wrong dimensions for scores or labels!');
end

% assert(all(size(scores)==size(labels)));
% nImg = size(scores,1);


gt = labels;
[~,si]=sort(-scores);
tp=gt(si)>0;
fp=gt(si)<0;

fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/sum(gt>0);
prec=tp./(fp+tp);

% compute average precision

ap=0;
for t=0:0.1:1
  p=max(prec(rec>=t));
  if isempty(p)
    p=0;
  end
  ap=ap+p/11;
end

