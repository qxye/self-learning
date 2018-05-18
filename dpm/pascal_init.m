
% initialize the PASCAL development kit 
tmp = pwd;
cd(tmp);%added by ye
cd(VOCdevkit);
addpath([cd '/VOCcode']);
VOCinit;
cd(tmp);
