rng(1)
r = sqrt(3*rand(100,1));
t = 2*pi*rand(100,1);
data1 = [r.*cos(t), r.*sin(t)];

figure;
plot(data1(:,1),data1(:,2),'r.', 'MarkerSize',15);
theclass = ones(100,1)

%fitting a one class svm
c1 = fitcsvm(data1,theclass,'Kernelfunction', 'rbf', 'Nu', 0.5, 'Classnames', [1]);
hold on;

%griding and predicting
d = 0.01;
[x1Grid, x2Grid] = meshgrid(min(data1(:,1)):d:max(data1(:,1)),...
    min(data1(:,2)):d:max(data1(:,2)));
xGrid = [x1Grid(:),x2Grid(:)];
[~,scores] = predict(c1,xGrid);

%plotting the support vectors
plot(data1(c1.IsSupportVector,1),data1(c1.IsSupportVector,2),'ko');

%ploting the fitting boundary
contour(x1Grid, x2Grid,reshape(scores(:,1),size(x1Grid)),[0,0],'k');

%predicting
[~,scores] = predict(c1,data1)