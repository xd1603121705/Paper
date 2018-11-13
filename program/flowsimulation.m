close all;
clear all;
clc;

%% 显示原图像
grayPic = imread('youxiajiao.png');
%grayPic = imread('step1_filter_50.bmp');
%figure('name', '初始图像'); imshow(grayPic);

%% 灰度化
mysize = size(grayPic);
if numel(mysize)>2
    grayPic = rgb2gray(grayPic);
end

figure('name', '原始灰度图像'); imshow(grayPic);

% 获取grayPic的行列值
[imageHeight,imageWidth] = size(grayPic); 

%% 计算水流方向矩阵（选择单流向D8策略）
% 32    64    128
% 16    x     1
% 8     4     2

% 水流方向矩阵
flowDirection = zeros(imageHeight,imageWidth);

% 数据边缘的grid点赋予指向边缘的方向值
for j=1:imageWidth
    flowDirection(1, j) = 64;
    flowDirection(imageHeight, j) = 4;
end
for i=1:imageHeight
    flowDirection(i, 1) = 16;
    flowDirection(i, imageHeight) = 1;
end

for i=2:imageHeight-1
    for j=2:imageWidth-1
        diff1 = grayPic(i, j) - grayPic(i, j+1);
        diff2 = (grayPic(i, j) - grayPic(i+1, j+1)) / sqrt(2);
        diff4 = grayPic(i, j) - grayPic(i+1, j);
        diff8 = (grayPic(i, j) - grayPic(i+1, j-1)) / sqrt(2);
        diff16 = grayPic(i, j) - grayPic(i, j-1);
        diff32 = (grayPic(i, j) - grayPic(i-1, j-1)) / sqrt(2);
        diff64 = grayPic(i, j) - grayPic(i-1, j);
        diff128 = (grayPic(i, j) - grayPic(i-1, j+1)) / sqrt(2);
        diffArray = [diff1, diff2, diff4, diff8, diff16, diff32, diff64, diff128]; %8个方向的距离权落差
        diffMax = max(diffArray); %最大坡降
        diffcount = 0;  % diff = max的计数
        inx = zeros(1, 8); % diff = max的索引
     
        %统计diff = max的计数并存储索引
        for c=1:8
            if(diffArray(c) == diffMax)
                diffcount = diffcount + 1;
                inx(c) = 1;
            end
        end
        
        % 用于diff = 0时计算落差值
        value = inx(1)*1 + inx(2)*2 + inx(3)*4 + inx(4)*8 + ...
                inx(5)*16 + inx(6)*32 + inx(7)*64 + inx(8)*128; 
        
        if(diffMax < 0)
            flowDirection(i, j) = -1; % 最大落差值小于0的赋值-1表示方向未定
        elseif(diffMax == 0)
            if(diffcount == 8)
                flowDirection(i, j) = 255; % 8个邻域高程值都跟中心相同的话，赋255
            else
                flowDirection(i, j) = value; %否则赋相加的值
            end
        else % 对于〉0的值，直接选第一个相等的方向
            switch diffMax
                case diff1
                    flowDirection(i, j) = 1;
                case diff2
                    flowDirection(i, j) = 2;
                case diff4
                    flowDirection(i, j) = 4;
                case diff8
                    flowDirection(i, j) = 8;
                case diff16
                    flowDirection(i, j) = 16;
                case diff32
                    flowDirection(i, j) = 32;
                case diff64
                    flowDirection(i, j) = 64;
                case diff128
                    flowDirection(i, j) = 128;
            end % end of switch
        end % end of if(diffMax < 0)
    end % end of for(j)
end % end of for(i)

%% 计算水流累计量

water = zeros(imageHeight, imageWidth);
for i=1:imageHeight
    for j=1:imageWidth
        water(i, j)=1;
    end
end

% 从左上角开始落雨
for i=2:imageHeight-1
    for j=2:imageWidth-1
        switch flowDirection(i, j) % 根据当前节点的流水方向将其水量添加到对应方向
            case 1
                water(i, j+1) = water(i, j+1) + water(i, j);
            case 2
                water(i+1, j+1) = water(i+1, j+1) + water(i, j);
            case 4
                water(i+1, j) = water(i+1, j) + water(i, j);
            case 8
                water(i+1, j-1) = water(i+1, j-1) + water(i, j);
            case 16
                water(i, j-1) = water(i, j-1) + water(i, j);
            case 32
                water(i-1, j-1) = water(i-1, j-1) + water(i, j);
            case 64
                water(i-1, j) = water(i-1, j) + water(i, j);
            case 128
                water(i-1, j+1) = water(i-1, j+1) + water(i, j);
            case 255
                water(i, j) = max([water(i-1, j-1), water(i-1, j), water(i-1, j+1),...
                                  water(i, j-1), water(i, j),water(i, j+1),...
                                  water(i+1, j-1), water(i-1, j-1), water(i-1, j-1)]);
        end
    end
end


% 从右下角模拟落雨
for i=imageHeight-1:-1:2
    for j=imageWidth-1:-1:2
        switch flowDirection(i, j)
            case 1
                water(i, j+1) = water(i, j+1) + water(i, j);
            case 2
                water(i+1, j+1) = water(i+1, j+1) + water(i, j);
            case 4
                water(i+1, j) = water(i+1, j) + water(i, j);
            case 8
                water(i+1, j-1) = water(i+1, j-1) + water(i, j);
            case 16
                water(i, j-1) = water(i, j-1) + water(i, j);
            case 32
                water(i-1, j-1) = water(i-1, j-1) + water(i, j);
            case 64
                water(i-1, j) = water(i-1, j) + water(i, j);
            case 128
                water(i-1, j+1) = water(i-1, j+1) + water(i, j);
            case 255
                water(i, j) = max([water(i-1, j-1), water(i-1, j), water(i-1, j+1),...
                                  water(i, j-1), water(i, j),water(i, j+1),...
                                  water(i+1, j-1), water(i-1, j-1), water(i-1, j-1)]);
        end
    end
end

% 从左下角模拟落雨
for i=imageHeight-1:-1:2
    for j=2:imageWidth-1
        switch flowDirection(i, j)
            case 1
                water(i, j+1) = water(i, j+1) + water(i, j);
            case 2
                water(i+1, j+1) = water(i+1, j+1) + water(i, j);
            case 4
                water(i+1, j) = water(i+1, j) + water(i, j);
            case 8
                water(i+1, j-1) = water(i+1, j-1) + water(i, j);
            case 16
                water(i, j-1) = water(i, j-1) + water(i, j);
            case 32
                water(i-1, j-1) = water(i-1, j-1) + water(i, j);
            case 64
                water(i-1, j) = water(i-1, j) + water(i, j);
            case 128
                water(i-1, j+1) = water(i-1, j+1) + water(i, j);
            case 255
                water(i, j) = max([water(i-1, j-1), water(i-1, j), water(i-1, j+1),...
                                  water(i, j-1), water(i, j),water(i, j+1),...
                                  water(i+1, j-1), water(i-1, j-1), water(i-1, j-1)]);
        end
    end
end
% 从右上角模拟落雨
for i=2:imageHeight-1
    for j=imageWidth-1:-1:2
        switch flowDirection(i, j)
            case 1
                water(i, j+1) = water(i, j+1) + water(i, j);
            case 2
                water(i+1, j+1) = water(i+1, j+1) + water(i, j);
            case 4
                water(i+1, j) = water(i+1, j) + water(i, j);
            case 8
                water(i+1, j-1) = water(i+1, j-1) + water(i, j);
            case 16
                water(i, j-1) = water(i, j-1) + water(i, j);
            case 32
                water(i-1, j-1) = water(i-1, j-1) + water(i, j);
            case 64
                water(i-1, j) = water(i-1, j) + water(i, j);
            case 128
                water(i-1, j+1) = water(i-1, j+1) + water(i, j);
            case 255
                water(i, j) = max([water(i-1, j-1), water(i-1, j), water(i-1, j+1),...
                                  water(i, j-1), water(i, j),water(i, j+1),...
                                  water(i+1, j-1), water(i-1, j-1), water(i-1, j-1)]);
        end
    end
end

% figure('name', '初始汇水量图'); imshow(water);

for i=1:imageHeight
    for j=1:imageWidth
        if(water(i, j) < 255)
            water(i, j) = 0;
        %else
            %water(i, j) = 255;
        end
    end
end

figure('name', '汇水量图'); imshow(water);

%{
for i=2:imageHeight-1
    for j=2:imageWidth-1
        if(water(i, j) ~= 0)
            if(water(i, j+1) ~= 0)
                plot([i, i],[j, j+1]);
                hold on
            end
            if(water(i+1, j+1) ~= 0)
                plot([i, i+1],[j, j+1]);
                hold on
            end
            if(water(i+1, j) ~= 0)
                plot([i, i+1],[j, j]);
                hold on
            end
            if(water(i+1, j-1) ~= 0)
                plot([i, i+1],[j, j-1]);
                hold on
            end
            %{
            if(water(i, j-1) ~= 0)
                plot([i, i],[j, j-1]);
            end
            if(water(i-1, j-1) ~= 0)
                plot([i, i-1],[j, j-1]);
            end
            if(water(i-1, j) ~= 0)
                plot([i, i-1],[j, j]);
            end
            if(water(i-1, j+1) ~= 0)
                plot([i, i-1],[j, j+1]);
            end
            %}
        end
    end
end
%}

afterthin = bwmorph(water,'thin',Inf);
figure('name', '细化之后图像'); imshow(afterthin);
afterspur = bwmorph(afterthin, 'spur');
% figure('name', 'spur之后图像'); imshow(afterspur);




            




