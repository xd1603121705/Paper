close all;
clear all;
clc;

%% 显示原图像
grayPic = imread('test.png');
%grayPic = imread('step1_filter_50.bmp');
%figure('name', '初始图像'); imshow(grayPic);

%% 灰度化
mysize = size(grayPic);
if numel(mysize)>2
    grayPic = rgb2gray(grayPic);
end

%figure('name', '灰度化后图像'); imshow(grayPic);

%%
t=graythresh(grayPic); %确定灰度阈值
imbinarize(grayPic,t);

%% 提取骨架
subplot(2, 2, 1);
%figure('name', '灰度化后图像'); imshow(grayPic);
imshow(grayPic);
title('原始图像');

bw2 = bwmorph(grayPic, 'remove');
subplot(2, 2, 2);
imshow(bw2);
title('移除内部像素');

bw3 = bwmorph(grayPic, 'skel', Inf);
subplot(2, 2, 3);
imshow(bw3);
title('骨架提取');

bw4 = bwmorph(bw3, 'spur', Inf);
subplot(2, 2, 4);
imshow(bw4);
title('消刺');





