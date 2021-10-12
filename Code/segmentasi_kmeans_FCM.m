clc; clear; close all;

%load image
Img = imread('MRI (2).jpg');
grayImage = double(rgb2gray(Img));
ukuran = size(grayImage);
[baris, kolom] = size(grayImage);
ukurantumor = round((baris*kolom)/1750);

% subplot(3, 3, 1);
% imshow(Img, []);
% title('Original Image');

subplot(3, 3, 1);
imshow(grayImage, []);
title('Grayscale Image');

numberOfClasseskmeans = 4;
numberOfClassesfcm = 3;
indekskmeans = kmeans(grayImage(:), numberOfClasseskmeans); %kmeans level 1
[~,indeksfcm] = fcm(indekskmeans(:), numberOfClassesfcm, 3); %FCM sebagai level 2

h = subplot(3, 3, 2);
hasilkmeans = reshape(indekskmeans, ukuran);
imshow(hasilkmeans, []);
title('Classified Image kmeans');
colormap(h,parula);

h = subplot(3, 3, 3);
[~,label] = max(indeksfcm, [], 1);
hasilfcm = reshape(label, ukuran);
imshow(hasilfcm, []);
title('Classified Image kmeans + fcm');
colormap(h,parula);

%-------------------------------------------------------------------------------------
class1 = zeros(ukuran);
area1 = zeros(numberOfClasseskmeans,1);

for n = 1:numberOfClasseskmeans
    class1(:,:,n) = hasilkmeans == n;
    area1(n) = sum(sum(class1(:,:,n)));
end

[~,min_area1] = min(area1);

object1 = hasilkmeans == min_area1;
bw1 = medfilt2(object1);

subplot(3, 3, 4);
imshow(bw1, []);
title('Median Filter Kmeans');

bw1 = bwareaopen(bw1, ukurantumor);

subplot(3, 3, 5);
imshow(bw1, []);
title('Morfologikal Kmeans');

s1 = regionprops(bw1,'BoundingBox');
bbox1 = cat(1, s1.BoundingBox);
RGB1 = insertShape(Img, 'FilledRectangle', bbox1, 'Color', 'yellow', 'Opacity', 0.3);
RGB1 = insertObjectAnnotation(RGB1,'rectangle',bbox1,'Object','TextBoxOpacity',0.9,'FontSize',18);
subplot(3, 3, 6);
imshow(RGB1,[]);
title('Detected Object Kmeans');

%----------------------------------------------------------------------------------
class = zeros(ukuran);
area = zeros(numberOfClassesfcm,1);

for n = 1:numberOfClassesfcm
    class(:,:,n) = hasilfcm == n;
    area(n) = sum(sum(class(:,:,n)));
end

[~,min_area] = min(area);

object = hasilfcm == min_area;
bw = medfilt2(object);

subplot(3, 3, 7);
imshow(bw, []);
title('Median Filter kmeans + FCM');

bw = bwareaopen(bw, ukurantumor);

subplot(3, 3, 8);
imshow(bw, []);
title('Morfologikal kmeans + FCM');

s = regionprops(bw,'BoundingBox');
bbox = cat(1, s.BoundingBox);
RGB = insertShape(Img, 'FilledRectangle', bbox, 'Color', 'yellow', 'Opacity', 0.3);
RGB = insertObjectAnnotation(RGB,'rectangle',bbox,'Object','TextBoxOpacity',0.9,'FontSize',18);
subplot(3, 3, 9);
imshow(RGB,[]);
title('Detected Object kmeans + FCM');