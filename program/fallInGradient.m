close all; % �ر������Ѵ򿪴���
clear variables; % ����ڴ��еı���
% clc ��յ�ǰ��������

debugStop=0; % ��������debugStop

%% ------��ʾ��ԭʼ��ͼ��
% fileName='test1.png';
% fileName='coins.png';
% fileName='pears.png';
fileName='step1_filter_50.bmp';
%fileName='step1_filter_30.bmp';

file = 'test1.png';
origenPic = imread(file);

 % imread�����ļ�
grayPic = imread(fileName);
mysize=size(grayPic); % size�����������������������ά������������ά��...���˴�mysizeΪ[600, 600]
if numel(mysize)>2 % numel������������������ָ��������Ԫ�ظ���������ͼ��A��numel(A)������������
                   % ����ͼ�����飬�Ҷ�ͼΪ��ά���飬RGBͼΪ��ά���飬�˴�if����ж��Ƿ�Ϊ�Ҷ�ͼ
    grayPic=rgb2gray(grayPic); % ���ǻҶ�ͼ��������rgb2gray����ת���ɻҶ�ͼ
end 

% figure����һ��������ʾͼ������Ĵ��ڶ��󣬿���ͨ������ָ�����ڵ����ԣ�imshow��ʾͼ��
% һ�����ʹ�ã���ֹͼ�񸲸���һ����ʾ�Ľ��
figure('Name','��ԭʼ�ҶȻ�ͼ��'); imshow(grayPic); 

[imageHeight,imageWidth] = size(grayPic); % ��ȡgrayPic������ֵ

chengFang=0.0;

imageFloat=double(grayPic)/255; % ��0~255�ľ���ֵת���0~1�������

%% �Լ������ݶȵĹ���
imgGradientMine=zeros(imageHeight,imageWidth);
for i=2:imageHeight
    for j=2:imageWidth
        chengFang=( imageFloat(i,j)-imageFloat(i-1,j))^2 + ( imageFloat(i,j)-imageFloat(i,j-1))^2;
        imgGradientMine(i,j)=sqrt(chengFang);
    end
end
% figure('Name','�Լ�ֱ�Ӽ���õ����ݶȳ�ͼ��');
% imshow(imgGradientMine*20);


%% Sobel�������ݶ�
imgGradient=zeros(imageHeight,imageWidth); %zeros�������飬����Ϊ����ֵ��������ȫ����0���

hy=fspecial('sobel'); % fspecial������������Ԥ������˲�����
hx=hy'; % sobel����ת��������һ������ģ��

% imfilter����������������άͼ������˲�
% g=imfilter(f,w,filtering_mode,boundary_options,size_optinos)
% f������ͼ��wΪ�˲�ģ�壬filtering_modeΪ�˲�ģʽ��boundary_optionsΪ�߽�ѡ�gΪ�˲����
ly=imfilter(double(grayPic),hy,'replicate');
lx=imfilter(double(grayPic),hx,'replicate');
imgGradient=sqrt(lx.^2 + ly.^2);

 figure('Name','Sobel����õ����ݶȳ�ͼ��'); 
 imshow(imgGradient,[]);


%% ���ݶȳ���ģ���������
hFigure1 = figure('Name','���ݶȳ���ģ������'); 
% set����������������������
% gcf���ص�ǰfigure����ľ��ֵ��gca���ص�ǰaxes����ľ��ֵ
set(gcf, 'position',[200 200 800 600]);

% axes������������ϵͼ�ζ��󣬲��������ľ��
h_Axes_BKG = axes('Parent', hFigure1);
axes(h_Axes_BKG);
set(gca, 'box','off', 'xtick',[], 'ytick',[], 'units','pixels' );
 h_BKG = imshow(imgGradient,[]);

%---------------------��������
% displayGradient=imgGradient;
% for i=1:100
%     displayGradient(i,100)=200;
%     h_BKG = imshow(displayGradient,[]);           
%     drawnow        
% %     pause(1/100);
% end



% ��ˮ���㷨�����ݶ�ͼ����з�ˮ���㷨����
L = watershed(imgGradient); % ���ݶȳ����з�ˮ�봦��
% L = watershed(imageFloat); % ��ԭʼͼ����з�ˮ�봦��
figure('Name','��ˮ��ָ��ݶȼ�ͼ�� '); 
imshow(L);

figure('Name','��ˮ��ָ��ݶȼ�ͼ��--���� '); 
%imshow(L,[]);
imshow(L*8,[]);

Lrgb=label2rgb(L);
figure('Name','��ˮ��ָ��ݶȼ���ɫͼ�� '); 
imshow(Lrgb);

% ��������������ͼ����ͨ���������ѡȡһ���㣬�Ҽ���������
disp('������������ȡ��Ҫ�ĵ�');
disp('��������Ҽ���ȡ����');
xi=0; 
yi=0;
but=1;

% ginput�ṩ��һ��ʮ�ֹ��ʹ�����ܸ���ȷ��ѡ����������Ҫ��λ�ã�����������ֵ
% [x,y,button] = ginput(n)  �����ӵ�ǰ������ͼ��ѡ��n���㣬��������n�����
% ��������ֵx��y�ͼ���ť�ı�ʾ������button��һ��������������ʾ�û�������һ
% ��������1=�����2=�У�3=�ң��򷵻ذ�����ASCII��ֵ
while but==1
    [xi,yi,but]=ginput(1);
end

%-----------------��ʾϸ������
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
figure('Name','ָ����ŵ��ݶȼ���ɫͼ�� '); 
imshow(subLabelRGB);

BW2 = bwmorph(subLabelMat,'thin',Inf);
figure, imshow(BW2)


maxLabel=max(max(L));
%% --------------------�����еı����������ͼ���ļ�
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

%% ----------------------�ж�ɽ�����򣺸��ݼ�ˮ��������Ϣ�������ڵ�������ˮ���к��θߵļ�ˮ��������

deleteLabel=uint16(zeros(1,maxLabel)); %��¼Ҫɾ����label��ÿ��Label���±��Ӧ��Ӧ��labelֵ��ÿ��Ԫ���е���ֵ��
                                     %��¼��Ԫ�ض�Ӧ��Label��ɾ���㷨��������ñ�ɾ���Ĵ�����ֻҪ��Ԫ�ص�ֵ���㣬˵����Ԫ�ض�Ӧ��labelӦ�ôӷ�ˮ��ͼ��ɾ��
for i=1:labelSize(1)
    for j=1:labelSize(2)        
        if L(i,j)==0 %����Ƿ�ˮ��ı߽�ֵ0
            if j~=1 && j~=labelSize(2) %�������ͼ�����ҵ���߽�
                if L(i,j-1)~=0 && L(i,j+1)~=0 % ���������������򶼲��Ǳ߽���ܽ��бȽϡ�
                    
                    
                    if origenPic(i,j-1)>origenPic(i,j+1)  %��Ϊ��Ҫ�ж�ɽ�ȣ����Խ����θߵ�һ���������ӵ���ɾ������
                    %if grayPic(i,j-1)<grayPic(i,j+1)  %��Ϊ��Ҫ�ж�ɽ�壬���Խ����ε͵�һ���������ӵ���ɾ������                        
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
figure('Name','����ɽ�Ȳ�ɫͼ�� '); 
imshow(finalLabelRGB);


debugStop=debugStop;