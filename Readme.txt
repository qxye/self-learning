%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
This program is for [self-learning scene-specific object detection](chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Farxiv.org%2Fpdf%2F1611.07544.pdf).
copyright Reserved by University of Chinese Academy of Sciences.
It is free for academy purpose.
Please contacet qxye@ucas.ac.cn if you have more problems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Runtime enviroment: Matalb12 or later vergion, 

Configuration:

1. Download the Edgebox proposal generation code from http://vision.ucsd.edu/~pdollar/research.html

2. Download the DPM code from Ross Grishick's UC berkely websit

3. Supose the video name is 'PETS09-S2L2.avi', put the video in the dataset 'data\'

4. Make a folder as the name of video

5. Randomly prepare >1000 negtive images in the data\videoname\neg folder
   Prepare the neg_filelist.txt in the data\videoname foler

6. Run Demo by inputting st_learning('.\data\PETS09-S2L2.avi')