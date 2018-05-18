function bboxPoints = bbox2points(bbox)

bboxPoints = [bbox(1) bbox(2);            
            bbox(1) bbox(2)+bbox(4);
            bbox(1)+bbox(3) bbox(2)+bbox(4);
            bbox(1)+bbox(3) bbox(2)];

%bboxPoints = cornerPoints(locations);

end