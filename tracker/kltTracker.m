%creating a point Tracker
function  [bbox bboxPoints oldPoints pointTracker videoFrame] =kltTracker(pointTracker, videoFrame,oldPoints, bboxPoints)

 % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    if size(visiblePoints, 1) >= 10 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
 
        % Apply the transformation to the bounding box points
        bboxPoints = transformPointsForward(xform, bboxPoints);                
        
        [bbox boundingPoints] = boundingBox(bboxPoints);

        % Insert a bounding box around the object being tracked
        bboxPolygon = reshape(boundingPoints', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, ...
           'LineWidth', 2);

        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
    else
        bbox = [];
    end
        
end

function [bbox bpoints] = boundingBox(bboxPoints)

x1 = min(bboxPoints(:,1));
x2 = max(bboxPoints(:,1));
y1 = min(bboxPoints(:,2));
y2 = max(bboxPoints(:,2));

wid = x2-x1+1;
hei = y2-y1+1;

% %shrinking
x1 = x1+0.1*wid;
x2 = x2-0.1*wid; 

bpoints = [x1 y1; x1 y2; x2 y2; x2 y1];
bbox = [x1 y1 x2-x1+1 y2-y1+1];

end