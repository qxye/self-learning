# Self-learning Scene-specific Pedestrian Detectors using a Progressive Latent Model

### Introduction
A self-learning approach is proposed towards solving scene-specific pedestrian detection problem without any human¡¯ annotation involved. The selflearning approach is deployed as progressive steps of object
discovery, object enforcement, and label propagation. In the learning procedure, object locations in each frame are treated as latent variables that are solved with a progressive latent model (PLM). Compared with conventional latent models, the proposed PLM incorporates a spatial regularization term to reduce ambiguities in object proposals and to enforce object localization, and also a graph-based lab propagation to discover harder instances in adjacent frames. With the difference of convex (DC) objective functions, PLM can be efficiently optimized with a concaveconvex programming and thus guaranteeing the stability of self-learning. Extensive experiments demonstrate that even without annotation the proposed self-learning approach outperforms weakly supervised learning approaches, while achieving comparable performance with transfer learning and fully supervised approaches.

This is a matlab code of [Self-learning Scene-specific Pedestrian Detectors using a Progressive Latent Model](chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Farxiv.org%2Fpdf%2F1611.07544.pdf).copyright Reserved by University of Chinese Academy of Sciences.
It is free for academy purpose.
Please contacet qxye@ucas.ac.cn if you have more problems

Runtime enviroment: Matalb12 or later vergion, 

### Configuration:

1. Download the Edgebox proposal generation code from http://vision.ucsd.edu/~pdollar/research.html

2. Download the DPM code from Ross Grishick's UC berkely websit

3. Supose the video name is 'PETS09-S2L2.avi', put the video in the dataset 'data\'

4. Make a folder as the name of video

5. Randomly prepare >1000 negtive images in the data\videoname\neg folder
   Prepare the neg_filelist.txt in the data\videoname foler

6. Run Demo by inputting st_learning('.\data\PETS09-S2L2.avi')