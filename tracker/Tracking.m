function  [trackedBoxes videoFrame] = Tracking(aviPlayer,numFrames,start_frame,end_frame,bbs,scale)

end_frame = min(end_frame,numFrames);

sz = size(bbs,1);
if(sz<1) trackedBoxes = []; 
     videoFrame = read(aviPlayer, end_frame);
    videoFrame = imresize(videoFrame, scale);
    return;
end;

%tracking of multiple object
trackedBoxes = [];
idx = 1;
for i =1:sz
    
    %tracking of a single objects
    bb = bbs(i,:);
    [trackedBox videoFrame] = TrackingOne(aviPlayer,numFrames,start_frame,end_frame,bb,scale);    
    
    %aspect ratio checking
    
    if ~isempty(trackedBox)       
    trackedBoxes(idx,:) = [trackedBox bbs(i,5:end)];
    idx = idx +1;
    end
    
end

a =0;

end

function  [trackedBox videoFrame] = TrackingOne(aviPlayer,numFrames,start_frame,end_frame,bb,scale)

trackedBox = bb;
bbox       = bb(1:4);

videoFrame = read(aviPlayer, start_frame); 
videoFrame = imresize(videoFrame, scale);
% [bbox, bboxPoints] = DetectFace(videoFrame);
%getting the corner points
bboxPoints = bbox2points(bbox);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detect feature points in the face region.
points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', uint16(bbox));
% Display the detected points.
%imshow(videoFrame), hold on, title('Detected features');
%plot(points);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, videoFrame);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end_frame = min(end_frame,numFrames);
oldPoints = points;
idx = 1;

for i=start_frame:end_frame
     % get the next frame
    videoFrame = read(aviPlayer, i);
    videoFrame = imresize(videoFrame, scale);
    
    [trackedBox bboxPoints oldPoints pointTracker videoFrame] =...
        kltTracker(pointTracker, videoFrame,oldPoints, bboxPoints);

    % Display the annotated video frame using the video player object
    %imshow(videoFrame);
    
    idx = idx+1;
end

% Clean up
release(pointTracker);

end