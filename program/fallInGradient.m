close all; % 关闭所有已打开窗口
clear variables; % 清空内存中的变量
% clc 清空当前窗口命令

debugStop=0; % 创建变量debugStop

%% ------显示最原始的图像
% fileName='test1.png';
% fileName='coins.png';
% fileName='pears.png';
fileName='step1_filter_50.bmp';
%fileName='step1_filter_30.bmp';

file = 'test1.png';
origenPic = imread(file);

 % imread读入文件
grayPic = imread(fileName);
mysize=size(grayPic); % size返回数组的行数，列数（二维），个数（三维）...，此处mysize为[600, 600]
if numel(mysize)>2 % numel方法返回数组中满足指定条件的元素个数，对于图像A，numel(A)返回像素数。
                   % 对于图像数组，灰度图为二维数组，RGB图为三维数组，此处if语句判断是否为灰度图
    grayPic=rgb2gray(grayPic); % 若非灰度图，将其用rgb2gray方法转换成灰度图
end 

% figure创建一个用语显示图形输出的窗口对象，可以通过参数指定窗口的属性，imshow显示图像
% 一般组合使用，防止图像覆盖上一次显示的结果
figure('Name','最原始灰度化图像'); imshow(grayPic); 

[imageHeight,imageWidth] = size(grayPic); % 获取grayPic的行列值

chengFang=0.0;

imageFloat=double(grayPic)/255; % 将0~255的矩阵值转变成0~1方便计算

%% 自己的求梯度的过程
imgGradientMine=zeros(imageHeight,imageWidth);
for i=2:imageHeight
    for j=2:imageWidth
        chengFang=( imageFloat(i,j)-imageFloat(i-1,j))^2 + ( imageFloat(i,j)-imageFloat(i,j-1))^2;
        imgGradientMine(i,j)=sqrt(chengFang);
    end
end
% figure('Name','自己直接计算得到的梯度场图像');
% imshow(imgGradientMine*20);


%% Sobel算子求梯度
imgGradient=zeros(imageHeight,imageWidth); %zeros创建数组，参数为行列值，并将其全部用0填充

hy=fspecial('sobel'); % fspecial函数用来创建预定义的滤波算子
hx=hy'; % sobel算子转置设置另一个方向模板

% imfilter对任意类型数组或多维图像进行滤波
% g=imfilter(f,w,filtering_mode,boundary_options,size_optinos)
% f是输入图像，w为滤波模板，filtering_mode为滤波模式，boundary_options为边界选项，g为滤波结果
ly=imfilter(double(grayPic),hy,'replicate');
lx=imfilter(double(grayPic),hx,'replicate');
imgGradient=sqrt(lx.^2 + ly.^2);

 figure('Name','Sobel计算得到的梯度场图像'); 
 imshow(imgGradient,[]);


%% 在梯度场中模拟落雨过程
hFigure1 = figure('Name','在梯度场中模拟落雨'); 
% set函数用来给对象设置属性
% gcf返回当前figure对象的句柄值，gca返回当前axes对象的句柄值
set(gcf, 'position',[200 200 800 600]);

% axes函数创建坐标系图形对象，并返回它的句柄
h_Axes_BKG = axes('Parent', hFigure1);
axes(h_Axes_BKG);
set(gca, 'box','off', 'xtick',[], 'ytick',[], 'units','pixels' );
 h_BKG = imshow(imgGradient,[]);

%---------------------动画过程
% displayGradient=imgGradient;
% for i=1:100
%     displayGradient(i,100)=200;
%     h_BKG = imshow(displayGradient,[]);           
%     drawnow        
% %     pause(1/100);
% end



% 分水岭算法，对梯度图像进行分水岭算法处理
L = watershed(imgGradient); % 对梯度场进行分水岭处理
% L = watershed(imageFloat); % 对原始图像进行分水岭处理
figure('Name','分水岭分割梯度级图像 '); 
imshow(L);

figure('Name','分水岭分割梯度级图像--加亮 '); 
%imshow(L,[]);
imshow(L*8,[]);

Lrgb=label2rgb(L);
figure('Name','分水岭分割梯度级彩色图像 '); 
imshow(Lrgb);

% 下述操作用于在图像中通过左键单击选取一个点，右键单击结束
disp('单击鼠标左键点取需要的点');
disp('单击鼠标右键点取结束');
xi=0; 
yi=0;
but=1;

% ginput提供了一个十字光标使我们能更精确的选择我们所需要的位置，并返回坐标值
% [x,y,button] = ginput(n)  函数从当前的坐标图上选择n个点，并返回这n个点的
% 坐标向量值x、y和键或按钮的标示。参数button是一个整数向量，显示用户按下哪一
% 个鼠标键（1=左键，2=中，3=右）或返回按键的ASCII码值
while but==1
    [xi,yi,but]=ginput(1);
end

%-----------------显示细化操作
% bwmorph
 BW2 = bwmorph(L,'thin',Inf);
 figure, imshow(BW2)


labelSize=size(L);
subLabelMat=uint16(zeros(labelSize(1),labelSize(2)));

selectLabel=L(uint16(yi),uint16(xi));
for i=1:labelSize(1)
    for j=1:labelSize(2)
        if L(i,j)==selectLabel
            subLabelMat(i,j)=selectLabel;
        end
    end
end

subLabelRGB=label2rgb(subLabelMat);
figure('Name','指定标号的梯度级彩色图像 '); 
imshow(subLabelRGB);

BW2 = bwmorph(subLabelMat,'thin',Inf);
figure, imshow(BW2)


maxLabel=max(max(L));
%% --------------------将所有的标号区域都生成图像文件
% for number=1:maxLabel
%     subLabelMat=uint16(zeros(labelSize(1),labelSize(2)));
%     for i=1:labelSize(1)
%         for j=1:labelSize(2)
%             if L(i,j)==number
%                 subLabelMat(i,j)=number;
%             end
%         end
%     end        
%     
%     outFileName='.\sub\';
%     tempStr=num2str(number);
%     outFileName=strcat(outFileName,tempStr);
%     outFileName=strcat(outFileName,'.bmp');
%     
%     subLabelRGB=label2rgb(subLabelMat);
%     imwrite(subLabelRGB,outFileName);
% end
% 
% labelSize=labelSize;

%% ----------------------判断山谷区域：根据集水盆邻域信息，将相邻的两个集水盆中海拔高的集水盆消除。

deleteLabel=uint16(zeros(1,maxLabel)); %记录要删除的label。每个Label的下标对应相应的label值。每个元素中的数值，
                                     %记录该元素对应的Label在删除算法过程中因该被删除的次数，只要该元素的值非零，说明该元素对应的label应该从分水岭图中删除
for i=1:labelSize(1)
    for j=1:labelSize(2)        
        if L(i,j)==0 %如果是分水岭的边界值0
            if j~=1 && j~=labelSize(2) %如果不是图的左右的最边界
                if L(i,j-1)~=0 && L(i,j+1)~=0 % 如果左邻域和右邻域都不是边界才能进行比较、
                    
                    
                    if origenPic(i,j-1)>origenPic(i,j+1)  %因为是要判断山谷，所以将海拔高的一侧的区域添加到待删除区域
                    %if grayPic(i,j-1)<grayPic(i,j+1)  %因为是要判断山峰，所以将海拔低的一侧的区域添加到待删除区域                        
                        deleteLabel( L(i,j-1) )=deleteLabel( L(i,j-1) )+1;
                    else
                        deleteLabel( L(i,j+1) )=deleteLabel( L(i,j+1) )+1;
                    end       
                    
                     %if(grayPic(i, j) == uint8(50)  && L(i,j) ~= 0)
                         %deleteLabel( L(i,j) )=deleteLabel( L(i,j) )+1;
                     %end
                end
            end
        end
    end
end        

debugStop=debugStop;

finalLabel=L;
for i=1:labelSize(1)
    for j=1:labelSize(2)    
        if L(i,j)~=0
            if deleteLabel( L(i,j) )~=0
                finalLabel(i,j)=0;
            end        
        end
    end
end

finalLabelRGB=label2rgb(finalLabel);
figure('Name','最后的山谷彩色图像 '); 
imshow(finalLabelRGB);


debugStop=debugStop;