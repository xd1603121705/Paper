
%% -------------------双线性插值法缩放矩阵或图像-------------------------------
% description:
%       算法思想：将目标图像坐标映射到原图像，应用双线性插值法求坐标灰度值，构造目标图像。
%         伪代码： 输入：图像矩阵I，缩放因子（zmf>0，且当0<zmf<1时为缩小，当zmf>1时为放大）
%                 输出：图像矩阵I缩放后的矩阵ZI
%                step1：计算图像矩阵I的尺寸，记为IH*IW*ID（灰度图对应ID为1，彩色RGB图对应ID为3），
%                       接着生成一个(IH*zmf)*(IW*zmf)*ID的全零矩阵ZI，用来作为目标矩阵。
%                step2：将原图像矩阵I扩展一圈记作IT，大小为(IH*2)*(IW*2)*ID，扩展一圈的值跟原外圈
%                       对应位置处的值保持一致。
%                step3：将目标矩阵ZI的坐标(zi,zj)映射回（zi/zmf, zj/zmf）得到（x,y），由于（x,j）
%                       应用双线性不一定为整数，故向下取整得到（i,j），其中（x=i+u,y=j+v）,且u,v∈
%                       [0，1)，为小数部分，同时可以得到(i,j)。
%                step4：根据下面公式进行双线性插值：
%                       f(zi,zj) = f(x,y) = (1-u)(1-v)f(i,j) +
%                       (1-u)vf(i,j+1) + u(1-v)f(i+1,j) +
%                       uvf(i+1,j+1)(其中f(*)表示*处的像素灰度值)。
%                step5：重复step3-step4，至填充完矩阵ZI。
%
%       Input：
%             l：图像文件名或矩阵（整数值（0-255））
%           zmf：缩放因子，即缩放的倍数（zmf > 0，且当0 < zmf < 1时为缩小，zmf > 1时为放大）
%
%      Output：缩放后的图像矩阵Zl
%       Usage：
%           Zl = SSELMHSIC('ImageFileName', zmf)，对图像l进行zmf倍的缩放并展示
%           Or：
%           Zl = SSELMHSIC(l, zmf)，对矩阵l进行zmf倍的缩放并展示
%

function [Zl] = imblizoom(I, zmf)

%% step1：对数据进行预处理

if ~exist('I', 'var') || isempty(I)
    error('输入图像l未定义或为空！');
end

if ~exist('zmf', 'var') || isempty(zmf) || numel(zmf) ~= 1
    error('位移矢量zmf未定义或为空或zmf的元素个数超过2');
end

if ischar(I)
    [I, M] = imread(I);
end

if zmf <= 0
    error('缩放倍数应该大于0');
end

%% step2 通过原始图像和缩放因子得到新图像的大小，并创建新图像

[IH, IW, ID] = size(I);
ZIH = round(IH * zmf);
ZIW = round(IW * zmf);
Zl = zeros(ZIH, ZIW, ID);

%% step3 扩展矩阵l边缘

IT = zeros(IH + 2, IW + 2, ID); % 将原矩阵扩大一圈

IT(2:IH + 1, 2:IW + 1, :) = I;  % 圈内像素值与l保持一致

IT(1, 2:IW + 1, :) = I(1, :, :); % 新矩阵第一行和最后一行分别取原矩阵第一行和最后一行的值
IT(IH + 2, 2:IW + 1, :) = I(IH, :, :);

IT(2:IH + 1, 1, :) = I(:, 1, :); % 新矩阵第一列和最后一列分别取原矩阵第一列和最后一列的值
IT(2:IH + 1, IW + 2, :) = I(:, IW, :);

% 四个角像素点赋值
IT(1, 1, :) = I(1, 1, :);
IT(1, IW + 2, :) = I(1, IW, :);
IT(IH + 2, 1, :) = I(IH, 1, :);
IT(IH + 2, IW + 2, :) = I(IH, IW, :);

%% step4 将新图像的像素点（zi, zj）映射到原始图像（ii, jj）处，进行双线性插值

for zj = 1:ZIW
    for zi = 1:ZIH
        ii = (zi - 1) / zmf; i = floor(ii); % x轴映射并向下取整
        jj = (zj - 1) / zmf; j = floor(jj); % y轴映射并向下取整
        u = ii - i; v = jj - j;    % u, v表示点（x, y） 
        i = i + 1; j = j + 1; % 这里 +1 为了保证第一行能正确应用线性插值
        Zl(zi, zj, :) = (1 - u) * (1 - v) * IT(i, j, :) + (1 -u) * v * IT(i, j + 1, :)...
                          + u * (1 - v) * IT(i + 1, j, :) + u * v * IT(i + 1, j + 1, :);
    end
end
Zl = uint8(Zl);

%% step5 以图像的形式显示缩放后的矩阵

figure
imshow(I, M);
axis on
title(['原图像（大小：', num2str(IH),'*', num2str(IW), '*', num2str(ID), '）']);

figure
imshow(Zl, M);
axis on
title(['缩放后的图像（大小：', num2str(ZIH),'*', num2str(ZIW), '*', num2str(ID), '）']);
end




        
        






