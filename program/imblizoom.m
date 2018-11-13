
%% -------------------˫���Բ�ֵ�����ž����ͼ��-------------------------------
% description:
%       �㷨˼�룺��Ŀ��ͼ������ӳ�䵽ԭͼ��Ӧ��˫���Բ�ֵ��������Ҷ�ֵ������Ŀ��ͼ��
%         α���룺 ���룺ͼ�����I���������ӣ�zmf>0���ҵ�0<zmf<1ʱΪ��С����zmf>1ʱΪ�Ŵ�
%                 �����ͼ�����I���ź�ľ���ZI
%                step1������ͼ�����I�ĳߴ磬��ΪIH*IW*ID���Ҷ�ͼ��ӦIDΪ1����ɫRGBͼ��ӦIDΪ3����
%                       ��������һ��(IH*zmf)*(IW*zmf)*ID��ȫ�����ZI��������ΪĿ�����
%                step2����ԭͼ�����I��չһȦ����IT����СΪ(IH*2)*(IW*2)*ID����չһȦ��ֵ��ԭ��Ȧ
%                       ��Ӧλ�ô���ֵ����һ�¡�
%                step3����Ŀ�����ZI������(zi,zj)ӳ��أ�zi/zmf, zj/zmf���õ���x,y�������ڣ�x,j��
%                       Ӧ��˫���Բ�һ��Ϊ������������ȡ���õ���i,j�������У�x=i+u,y=j+v��,��u,v��
%                       [0��1)��ΪС�����֣�ͬʱ���Եõ�(i,j)��
%                step4���������湫ʽ����˫���Բ�ֵ��
%                       f(zi,zj) = f(x,y) = (1-u)(1-v)f(i,j) +
%                       (1-u)vf(i,j+1) + u(1-v)f(i+1,j) +
%                       uvf(i+1,j+1)(����f(*)��ʾ*�������ػҶ�ֵ)��
%                step5���ظ�step3-step4������������ZI��
%
%       Input��
%             l��ͼ���ļ������������ֵ��0-255����
%           zmf���������ӣ������ŵı�����zmf > 0���ҵ�0 < zmf < 1ʱΪ��С��zmf > 1ʱΪ�Ŵ�
%
%      Output�����ź��ͼ�����Zl
%       Usage��
%           Zl = SSELMHSIC('ImageFileName', zmf)����ͼ��l����zmf�������Ų�չʾ
%           Or��
%           Zl = SSELMHSIC(l, zmf)���Ծ���l����zmf�������Ų�չʾ
%

function [Zl] = imblizoom(I, zmf)

%% step1�������ݽ���Ԥ����

if ~exist('I', 'var') || isempty(I)
    error('����ͼ��lδ�����Ϊ�գ�');
end

if ~exist('zmf', 'var') || isempty(zmf) || numel(zmf) ~= 1
    error('λ��ʸ��zmfδ�����Ϊ�ջ�zmf��Ԫ�ظ�������2');
end

if ischar(I)
    [I, M] = imread(I);
end

if zmf <= 0
    error('���ű���Ӧ�ô���0');
end

%% step2 ͨ��ԭʼͼ����������ӵõ���ͼ��Ĵ�С����������ͼ��

[IH, IW, ID] = size(I);
ZIH = round(IH * zmf);
ZIW = round(IW * zmf);
Zl = zeros(ZIH, ZIW, ID);

%% step3 ��չ����l��Ե

IT = zeros(IH + 2, IW + 2, ID); % ��ԭ��������һȦ

IT(2:IH + 1, 2:IW + 1, :) = I;  % Ȧ������ֵ��l����һ��

IT(1, 2:IW + 1, :) = I(1, :, :); % �¾����һ�к����һ�зֱ�ȡԭ�����һ�к����һ�е�ֵ
IT(IH + 2, 2:IW + 1, :) = I(IH, :, :);

IT(2:IH + 1, 1, :) = I(:, 1, :); % �¾����һ�к����һ�зֱ�ȡԭ�����һ�к����һ�е�ֵ
IT(2:IH + 1, IW + 2, :) = I(:, IW, :);

% �ĸ������ص㸳ֵ
IT(1, 1, :) = I(1, 1, :);
IT(1, IW + 2, :) = I(1, IW, :);
IT(IH + 2, 1, :) = I(IH, 1, :);
IT(IH + 2, IW + 2, :) = I(IH, IW, :);

%% step4 ����ͼ������ص㣨zi, zj��ӳ�䵽ԭʼͼ��ii, jj����������˫���Բ�ֵ

for zj = 1:ZIW
    for zi = 1:ZIH
        ii = (zi - 1) / zmf; i = floor(ii); % x��ӳ�䲢����ȡ��
        jj = (zj - 1) / zmf; j = floor(jj); % y��ӳ�䲢����ȡ��
        u = ii - i; v = jj - j;    % u, v��ʾ�㣨x, y�� 
        i = i + 1; j = j + 1; % ���� +1 Ϊ�˱�֤��һ������ȷӦ�����Բ�ֵ
        Zl(zi, zj, :) = (1 - u) * (1 - v) * IT(i, j, :) + (1 -u) * v * IT(i, j + 1, :)...
                          + u * (1 - v) * IT(i + 1, j, :) + u * v * IT(i + 1, j + 1, :);
    end
end
Zl = uint8(Zl);

%% step5 ��ͼ�����ʽ��ʾ���ź�ľ���

figure
imshow(I, M);
axis on
title(['ԭͼ�񣨴�С��', num2str(IH),'*', num2str(IW), '*', num2str(ID), '��']);

figure
imshow(Zl, M);
axis on
title(['���ź��ͼ�񣨴�С��', num2str(ZIH),'*', num2str(ZIW), '*', num2str(ID), '��']);
end




        
        






