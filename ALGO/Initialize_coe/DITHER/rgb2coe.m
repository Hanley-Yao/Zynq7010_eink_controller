clear
RGBPic=imread('原图.bmp');

GrayPic=im2gray(RGBPic);%把RGB图像转化成灰度图像

H=size(GrayPic,2);%宽
V=size(GrayPic,1);%高

BlueNoisePic=imread('..\..\Blue_Noise_Dithering\T1024_L1.5_2208x1872\texture.png');
BlueNoisePic=im2gray(BlueNoisePic);%把RGB图像转化成灰度图像
%误差扩散抖动
EDPic = dither(GrayPic);
figure(1)
imshow(EDPic)

imwrite(EDPic,'误差扩散结果.bmp')

%傅里叶变换
EDPic=im2double(EDPic);
BF=fft2(EDPic);
BF=fftshift(BF);
BF=abs(BF);
T=log(BF+1);
T = uint8(mat2gray(T) * 255);
figure(2)
imshow(uint8(T));
imwrite(T,'误差扩散傅里叶变换结果.bmp')

%蓝噪声有序抖动
DPic=zeros(size(GrayPic,1));%创建矩阵

for v=1:V%实现抖动算法
    for h=1:H
        if(BlueNoisePic(v,h) < GrayPic(v,h))
            DPic(v,h) = 1;
        else
            DPic(v,h) = 0;
        end
    end
end

figure(3)
imshow(DPic)

imwrite(DPic,'蓝噪声结果.bmp')

%傅里叶变换
BDPic=im2double(DPic);
BF=fft2(BDPic);
BF=fftshift(BF);
BF=abs(BF);
T=log(BF+1);
T = uint8(mat2gray(T) * 255);
figure(4)
imshow(uint8(T));
imwrite(T,'蓝噪声傅里叶变换结果.bmp')

uint8 DPicN(V,H/4);%定义一个300*825深度为8位的矩阵

%W=sprintf('%02s',dec2bin(2));%白色
%B=sprintf('%02s',dec2bin(1));%黑色

W='1';%白色
B='0';%黑色

fid0 = fopen('img.coe','wt');
fprintf(fid0,'MEMORY_INITIALIZATION_RADIX=10;\n');
fprintf(fid0,'MEMORY_INITIALIZATION_VECTOR=\n');

for v=1:V
    for h=1:H/4
        if(DPic(v,h*4-3) == 1)
            pix1=B;
        else
            pix1=W;
        end
        if(DPic(v,h*4-2) == 1)
            pix2=B;
        else
            pix2=W;
        end
        if(DPic(v,h*4-1) == 1)
            pix3=B;
        else
            pix3=W;
        end
        if(DPic(v,h+3) == 1)
            pix4=B;
        else
            pix4=W;
        end
        pixN=[pix1,pix2,pix3,pix4];
        if(v*h==V*H/4)
            fprintf(fid0,'%02d;',bin2dec(pixN));
        else
            fprintf(fid0,'%02d,\n',bin2dec(pixN));
        end
    end
end

fclose(fid0);%关闭文件