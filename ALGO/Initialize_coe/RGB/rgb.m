 %  实现了将png格式的图片转换为数字图像处理中的常用RGB格式
clear
rgb1=imread('image_gray.png');%读取图片数据
imtool(rgb1)
r=rgb1(1:256,1:256,1);%取其中的R分量
g=rgb1(1:256,1:256,2);
b=rgb1(1:256,1:256,3);
uint32 rgb2[256,256];%定义一个256*256，深度为32位的矩阵
rgb2=bitor(bitshift(uint32(r),16),bitshift(uint32(g),8));
rgb2=bitor(rgb2,uint32(b));%进行或运算，将像素值填充入矩阵中
fid0 = fopen('image_gray.coe','wt');
fprintf(fid0,'MEMORY_INITIALIZATION_RADIX=16;\n');
fprintf(fid0,'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(fid0, '%02x,\n', rgb2');%将矩阵按照6位16进制数输出，填充0占位
fid0 = fclose(fid0);%关闭这个文件

zero=zeros(256,256);%清空显示区域
R=cat(3,r,zero,zero);%R分量图像
G=cat(3,zero,g,zero);
B=cat(3,zero,zero,b);
RGB=cat(3,r,g,b);%原始图像
%显示图像
subplot(2,2,1),imshow(R),title('红色分量');
subplot(2,2,2),imshow(G),title('绿色分量');
subplot(2,2,3),imshow(B),title('蓝色分量');
subplot(2,2,4),imshow(RGB);
