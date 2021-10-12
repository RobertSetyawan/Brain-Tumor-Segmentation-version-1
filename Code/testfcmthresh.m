clear;close all;
% Segmentasi Citra MRI
%===========================================================================================================
MRI = imread('MRI (5).jpg');
[rows, columns, numberOfColorChannels] = size(MRI);
subplot(3,4,1);
imshow(MRI);title('Original');
% Mengecek terlebih dahulu apakah citra masih RGB atau sudah Grayscale
if numberOfColorChannels > 1
	MRI = rgb2gray(MRI);
end
%==========================================================================,.=================================
% Mengaplikasikan threshold proses untuk mengubah citra menjadi citra biner
thresholdValue = 65;%berhasil 55 & 60 & 65 trial and error
binaryImage = MRI > thresholdValue;
% Menghilangkan bingkai yang kemungkinan terdapat pada citra saat proses
% akuisisi, dengan nilai default jarak konektivitas antar piksel adalah 8
binaryImage = imclearborder(binaryImage);
       
%===========================================================================================================
% Mengekstrak tulang tengkorak dan otak, dengan menggunakan fungsi BW area
% filter, dengan parameter bahwa 2 bulatan terbesar kemungkinan adalah
% tulang tengkorak atau otak itu sendiri
binaryImage = bwareafilt(binaryImage, 2);
% lakukan erosi untuk memisahkan antara pinggiran tulang tengkorak dengan
% otak
binaryImage = imopen(binaryImage, true(1));
% Setelah proses erosi, pada citra terdapat celah antara tulang tengkorak
% dan otak, kemudian ambil bulatan terbesar yang kemungkinan besar adalah
% otak
binaryImage = bwareafilt(binaryImage, 1);
% tutupi bagian kosong pada citra MRI menggunakan fungsi imfill
binaryImage = imfill(binaryImage, 'holes');
% Tebalkan citra hasil seleksi guna mengkompensasi pixel yang hilang
binaryImage = imdilate(binaryImage, true(1));

%===========================================================================================================
% Gabungkan antara hasil pemotongan tulang tengkorak dengan citra asli
skullFreeImage = MRI;
skullFreeImage(~binaryImage) = 0;

% TAmpilkan citra hasil pemotongan tulang tengkorak
subplot(3,4,2);
imshow(skullFreeImage);title('Skull Stripped Away');

%applying morphological process to image to enhanced the image
se1 = strel('diamond',2);
I1 = imclose(skullFreeImage, se1);
se2 = strel('diamond',3);
I2 = imopen(I1, se2);


ukuran = size(I2);
subplot(3,4,3);
imshow(I2);title('Morphological Enhancement');

%remove noise image
noiseremoveimage = filterwiener(I2,[3 3]);
subplot(3,4,4);
imshow(noiseremoveimage);title('Noise Remove Image');

%incerasing contrast
im=contrastadjs(noiseremoveimage);
subplot(3,4,5);
imshow(im);title('Contrast Adjustment');

%convert to intensity image
fim=mat2gray(im);
subplot(3,4,6);
imhist(fim);title('Intensity image');
 
%clustering image using fcm
[bwfim0,level0]=fcmthresh(fim,0);
[bwfim1,level1]=fcmthresh(fim,1);

k = subplot(3,4,7);
imshow(bwfim0);title(sprintf('FCM with level 0,level=%f',level0));
colormap(k,parula);

h = subplot(3,4,8);
imshow(bwfim1);title(sprintf('FCM with level 1,level=%f',level1));
colormap(h,parula);

subplot(3,4,9);
imshow(bwfim1);title(sprintf('Segmented MRI Image'));

%calculating tumor volume
[baris, kolom] = size(I2);
ukurantumor = round((baris*kolom)/300);
%ADDING area open for eliminating non tumor pixel
areaopen1=bwareaopen(bwfim1,ukurantumor);
subplot(3,4,10);
imshow(areaopen1);title(sprintf('Final Segmentation before area filtering'));

[i,nomor] = bwlabel(~areaopen1,4);
ukur = regionprops(i,'Area');

% area filtering
areaopen2 = bwareafilt(areaopen1, 1);
% areaopen=bwareaopen(bwfim1,150);
subplot(3,4,11);
imshow(areaopen2);title(sprintf('Final Segmentation after area filtering'));

%measure the area
measure=regionprops(areaopen2,'BoundingBox');
bbox = cat(1, measure.BoundingBox);
RGB = insertShape(MRI, 'FilledRectangle', bbox, 'Color', 'yellow', 'Opacity', 0.2);
RGB = insertObjectAnnotation(RGB,'rectangle',bbox,'Object','TextBoxOpacity',0.9,'FontSize',18);

% areaopen2 = imfill(areaopen1, 'holes');
% final = MRI;
% final(~areaopen1) = 0;
% 
cc = bwconncomp(areaopen1,4);
num = cc.NumObjects;

% numPixel = nnz(areaopen1);
ukuranpixel = regionprops(areaopen2, 'Centroid');

allCentroids = [ukuranpixel.Centroid];
centroidX = allCentroids(1:2:end); % Extract x centroids.
centroidY = allCentroids(2:2:end); % Extract y centroids.

% titikx = centroidX/baris;
% titiky = centroidY/kolom;
% 
% x = [0.1,titikx];
% y = [0.3,titiky];
% 
% arrow = annotation('textarrow',x,y,'String','Tumor');
% [i,num] = bwlabel(~areaopen2,4);
%figure;
subplot(3,4,12);
imshow(RGB);title(sprintf('Detected Tumor Area = %d',num));

%saving the result segmented image
uint8Image = uint8(255 * areaopen2);
imwrite(uint8Image,'segmentedimage.jpg');