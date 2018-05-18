cls='F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\train\Neg\'
D = dir([cls '*.jpg']);
length=size(D);
f=fopen('F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\train\Neg\neg.txt','w+');
for n=1:length(1)
    fprintf(f,'%s\r\n',D(n,1).name);
end
display('×ª»»³É¹¦£¡');