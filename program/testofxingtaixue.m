close all;
clear all;
clc;

%% ��ʾԭͼ��
grayPic = imread('test.png');
%grayPic = imread('step1_filter_50.bmp');
%figure('name', '��ʼͼ��'); imshow(grayPic);

%% �ҶȻ�
mysize = size(grayPic);
if numel(mysize)>2
    grayPic = rgb2gray(grayPic);
end

%figure('name', '�ҶȻ���ͼ��'); imshow(grayPic);

%%
t=graythresh(grayPic); %ȷ���Ҷ���ֵ
imbinarize(grayPic,t);

%% ��ȡ�Ǽ�
subplot(2, 2, 1);
%figure('name', '�ҶȻ���ͼ��'); imshow(grayPic);
imshow(grayPic);
title('ԭʼͼ��');

bw2 = bwmorph(grayPic, 'remove');
subplot(2, 2, 2);
imshow(bw2);
title('�Ƴ��ڲ�����');

bw3 = bwmorph(grayPic, 'skel', Inf);
subplot(2, 2, 3);
imshow(bw3);
title('�Ǽ���ȡ');

bw4 = bwmorph(bw3, 'spur', Inf);
subplot(2, 2, 4);
imshow(bw4);
title('����');





