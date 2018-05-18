function fea_vector = st_fea2scales(im,scale)

% pyra = featpyramid(im);
% Compute feature pyramid to represent a patch.
% pyra.feat{i} is the i-th level of the feature pyramid.
% pyra.scales{i} is the scaling factor used for the i-th level.
% pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% first octave halucinates higher resolution data.
% padx,pady optionally pads each level of the feature pyramid

%parameters
sbin      =8; 
interval  =1;

if(nargin <2) max_scale = 1;
else          max_scale = scale;

sc = 2 ^(1/interval);
imsize = [size(im, 1) size(im, 2)];
pyra.feat = cell(max_scale + interval, 1);
pyra.scales = zeros(max_scale + interval, 1);
pyra.imsize = imsize;

% our resize function wants floating point values
im = double(im);
for i = 1:interval
  %scaled = resize(im, 1/sc^(i-1));
  scaled = imresize(im, 1/sc^(i-1));
  % "first" 2x interval
  pyra.feat{i} = features(scaled, sbin/2);
  pyra.scales(i) = 2/sc^(i-1);
  % "second" 2x interval
  pyra.feat{i+interval} = features(scaled, sbin);
  pyra.scales(i+interval) = 1/sc^(i-1);
  % remaining interals
  for j = i+interval:interval:max_scale
    %scaled = resize(scaled, 0.5);
    scaled = imresize(scaled, 0.5);
    pyra.feat{j+interval} = features(scaled, sbin);
    pyra.scales(j+interval) = 0.5 * pyra.scales(j);
  end
end

