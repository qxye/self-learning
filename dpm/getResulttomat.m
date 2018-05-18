function getResulttomat()
gtids=textread('F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\test\test6.txt','%s');

for i=1:length(gtids)
  data=textread(['F:\[2012-1120]voc-latent-Pedestrian-plane\Plane\result\re2\',gtids{i},'.txt']);
  result{i,1}{1,1}=data;
   
end

save plresult result ;


end