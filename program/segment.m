clear all;
close all;
clc;

%% 显示原图像
grayPic = imread('test1.png');

% grayPic = imread('terrain.bmp');

%% 灰度化
mysize=size(grayPic);
if numel(mysize)>2
    grayPic=rgb2gray(grayPic);
end 

figure('Name','灰度化后图像'); imshow(grayPic);


%% 识别
[h,w] = size(grayPic);
maxPoint = zeros(h,w,2);  %用来保存局部最大极值点，1代表是最大局部极值点，0表示不是
minPoint = zeros(h,w,2);  %用来保存局部最小极值点，1代表是最小局部极值点，0表示不是


%% ====================================    
% 开始识别点，将地形图中所有的备选特征点选择出来。
% 识别算法：以步长step_length
% =============================

imageData=im2double(grayPic);

% --------300行的数据 
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

%% --------------------------------------分级处理
tempLineData=zeros(w);

filterStep=20;  %分级宽度。将1-256的灰度级按照filterStep宽度来分级，总共分作256/20级

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