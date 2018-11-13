clear all;
close all;
clc;

%% ��ʾԭͼ��
grayPic = imread('test1.png');

% grayPic = imread('terrain.bmp');

%% �ҶȻ�
mysize=size(grayPic);
if numel(mysize)>2
    grayPic=rgb2gray(grayPic);
end 

figure('Name','�ҶȻ���ͼ��'); imshow(grayPic);


%% ʶ��
[h,w] = size(grayPic);
maxPoint = zeros(h,w,2);  %��������ֲ����ֵ�㣬1���������ֲ���ֵ�㣬0��ʾ����
minPoint = zeros(h,w,2);  %��������ֲ���С��ֵ�㣬1��������С�ֲ���ֵ�㣬0��ʾ����


%% ====================================    
% ��ʼʶ��㣬������ͼ�����еı�ѡ������ѡ�������
% ʶ���㷨���Բ���step_length
% =============================

imageData=im2double(grayPic);

% --------300�е����� 
lineNumber=300;
currentLine=imageData(lineNumber,:);

titleString='Before filter:Curve for testData with line number ';
subTitle=num2str(lineNumber);
titleString=strcat(titleString,subTitle);

xCoord=1:1:length(currentLine);
figure('name',titleString);
plot(xCoord, currentLine*255);
axis([1,600,1,255]);
% axis auto;

%% --------------------------------------�ּ�����
tempLineData=zeros(w);

filterStep=20;  %�ּ���ȡ���1-256�ĻҶȼ�����filterStep������ּ����ܹ�����256/20��

for i = 1:h
   currentLine=imageData(i,:);
   for j=1:w
       tempData=imageData(i,j)*256;
%        tempData=round(tempData/filterStep)*filterStep;       
       tempData=ceil(tempData/filterStep)*filterStep;       
       tempData=tempData/256;
       
       imageData(i,j)=tempData;
   end
end

figure('Name','final');imshow(imageData);