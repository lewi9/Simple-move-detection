clear; clc; close all;
I1 = rgb2gray(imread("1.jpg"));
I2 = rgb2gray(imread("2.jpg"));
I3 = rgb2gray(imread("3.jpg"));

% wyrównianie histogramu
IE1 = histeq(I1);
IE2 = histeq(I2);
IE3 = histeq(I3);

% filtrowanie
IFE1 = medfilt2(IE1);
IFE2 = medfilt2(IE2);
IFE3 = medfilt2(IE3);

% binaryzacja
BIFE1 = (IFE1 > 109);
BIFE2 = (IFE2 > 109);
BIFE3 = (IFE3 > 109);

% różnica starego i nowego obrazu
P1 = abs(BIFE1 - BIFE2);
P2 = abs(BIFE2 - BIFE3);

% definiowanie obiektu strukturalnego
se = strel('disk',8);

% usuwanie mały nieistotnych zakłóceń
% wyróżnienie ruszonych elementów
openIm1 = imopen(P1, se);
openIm2 = imopen(P2, se);

% podkreślenie krawędzi
edgeIm1 = edge(openIm1);
edgeIm2 = edge(openIm2);

% nakreślenie krawędzi na obecnym obrazie
dilIm1 = imdilate(edge(BIFE2), se);
dilIm2 = imdilate(edge(BIFE3), se);

% połączenie rezultatów w celu detekcji ruchu
resIm1 = edgeIm1 & dilIm1;
resIm2 = edgeIm2 & dilIm2;

figure(1)
subplot(221)
imshow(I1)

subplot(222)
imshow(I2)

subplot(223)
imshow(P1)

subplot(224)
imshow(resIm1)

figure(2)
subplot(221)
imshow(I2)

subplot(222)
imshow(I3)

subplot(223)
imshow(P2)

subplot(224)
imshow(resIm2)

%% 
% need webcam addon
% need getkeywait addon
clear; clc; close all;

bin = 109;
se = strel('disk',8);

cam = webcam(1);
cam.Resolution = '640x480';

newImage = snapshot(cam);

finish=false;
set(gcf,'CurrentCharacter','@');
while ~finish
   CH = getkeywait(1);
   if CH == 'e'
       close all;
       break;
   end
   oldImage = newImage;
   newImage = snapshot(cam);

   I1 = rgb2gray(oldImage);
   I2 = rgb2gray(newImage);

   IE1 = histeq(I1);
   IE2 = histeq(I2);

   IFE1 = medfilt2(IE1);
   IFE2 = medfilt2(IE2);

   BIFE1 = (IFE1 > bin);
   BIFE2 = (IFE2 > bin);

   P1 = abs(BIFE1 - BIFE2);

   openIm1 = imopen(P1, se);

   edgeIm1 = edge(openIm1);

   dilIm1 = imdilate(edge(BIFE2), se);

   resIm1 = edgeIm1 & dilIm1;
   
   move = 255 * repmat(uint8(resIm1), 1, 1, 3);
   move(:,:,1) = move(:,:,1) * 255;
   move(:,:,2) = move(:,:,2) * 255;
   move(:,:,3) = move(:,:,3) * 0;

   result = imfuse(newImage, move, 'blend', 'Scaling', 'joint');
   imshow(result);
   
end

