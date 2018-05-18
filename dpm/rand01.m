
fp = fopen('F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\test\test6.txt','wt');
a = randperm(600);  % 生成1到100的随机排列
b = a(1:100); % 
for i=1:100
    n=length(num2str(a(i)));
    if(n==1)
        %k=['P000' num2str(a(i)) '.png'];
        k=['P000' num2str(b(i))];
    elseif(n==2)
         k=['P00' num2str(b(i))];  
        else
         k=['P0' num2str(b(i))];  
    end
    fprintf(fp, '%s\n', k);
end
 fclose(fp);
 c= a(101:600); % 
 fp = fopen('F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\train\pos3.txt','wt');
for i=1:500
    n=length(num2str(c(i)));
    if(n==1)
        %k=['P000' num2str(a(i)) '.png'];
        k=['P000' num2str(c(i)) '.png'];
    elseif(n==2)
         k=['P00' num2str(c(i)) '.png'];  
        else
         k=['P0' num2str(c(i)) '.png'];  
    end
    fprintf(fp, '%s\n', k);
end
