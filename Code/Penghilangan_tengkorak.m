clc;close all;
%===========================================================================================================

grayImage = imread('MRI (87).jpg');
[rows, columns, numberOfColorChannels] = size(grayImage);
% Mengecek terlebih dahulu apakah citra masih RGB atau Grayscale
if numberOfColorChannels > 1
	grayImage = grayImage(:, :, 2);
end
%===========================================================================================================
% Mengaplikasikan threshold proses untuk mengubah citra menjadi citra biner
thresholdValue = 65;%berhasil 55 & 60 & 65
binaryImage = grayImage > thresholdValue;
% Menghilangkan bingkai yang kemungkinan terdapat pada citra saat proses akuisisi
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
skullFreeImage = grayImage;
skullFreeImage(~binaryImage) = 0;

%===========================================================================================================
% Menyimpan hasil seleksi
uint8Image = uint8(skullFreeImage);
imwrite(uint8Image,'skullFreeImage.jpg');
