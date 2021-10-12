clc; clear; close all;
Img = imread('MRI (2).jpg');
grayImage = double(rgb2gray(Img));
ukuran = size(grayImage);
[baris, kolom] = size(grayImage);
ukurantumor = round((baris*kolom)/175);
subplot(3, 2, 1);
imshow(grayImage, []);
title('Grayscale Image');
numberOfClassesfcm = 3;
[~,indeksfcm] = fcm(grayImage(:), numberOfClassesfcm, 3); %FCM sebagai level 2
h = subplot(3, 2, 2);
[~,label] = max(indeksfcm, [], 1);
hasilfcm = reshape(label, ukuran);
imshow(hasilfcm, []);
title('Classified Image fcm');
colormap(h,parula);
class = zeros(ukuran);
area = zeros(numberOfClassesfcm,1);

%=================================================================================================%

for n = 1:numberOfClassesfcm
    class(:,:,n) = hasilfcm == n;
    area(n) = sum(sum(class(:,:,n)));
end

[~,min_area] = min(area);

object = hasilfcm == min_area;
bw = medfilt2(object);

subplot(3, 2, 3);
imshow(bw, []);
title('Median Filter FCM');

% bw = bwareaopen(bw, 200);

subplot(3, 2, 4);
imshow(bw, []);
title('Morfologikal FCM');

binaryImage = bwareafilt(bw, 2);

s = regionprops(binaryImage,'BoundingBox');
bbox = cat(1, s.BoundingBox);
RGB = insertShape(Img, 'FilledRectangle', bbox, 'Color', 'yellow', 'Opacity', 0.3);
RGB = insertObjectAnnotation(RGB,'rectangle',bbox,'Object','TextBoxOpacity',0.9,'FontSize',18);
subplot(3, 2, 5);
imshow(RGB,[]);
title('Detected Object FCM');