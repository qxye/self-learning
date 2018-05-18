function semiSupervised
%testing example
load fisheriris;
xdata = meas(51:end,3:4);
ydata = species(51:end);

idx1 = (strcmp(ydata,ydata(1))==1);
idx2 = (strcmp(ydata,ydata(1))==0);
ydata = [];
ydata(idx1) = 1; ydata(idx2) = -1; 
ydata = ydata';

%sampling training data
xL = xdata(1:2:size(xdata,1),:);
yL = ydata(1:2:size(ydata));
xU = xdata(2:2:size(xdata,1),:);
yU = ydata(2:2:size(ydata));

svmStruct =  svmtrain(xL,yL,'ShowPlot',true);

%graph based semi-supervised labeling
yU = graphLabeling(xL, yL, xU, 5);

pause(10);

hold on;
scatter(xU(:,1),xU(:,2));

pause(10);

idx1 = find(yU ==1);
idx2 = find(yU ==-1);
scatter(xU(idx1,1),xU(idx1,2),'MarkerFaceColor','g');
scatter(xU(idx2,1),xU(idx2,2),'MarkerFaceColor','r');

end


