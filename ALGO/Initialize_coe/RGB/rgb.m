 %  ʵ���˽�png��ʽ��ͼƬת��Ϊ����ͼ�����еĳ���RGB��ʽ
clear
rgb1=imread('image_gray.png');%��ȡͼƬ����
imtool(rgb1)
r=rgb1(1:256,1:256,1);%ȡ���е�R����
g=rgb1(1:256,1:256,2);
b=rgb1(1:256,1:256,3);
uint32 rgb2[256,256];%����һ��256*256�����Ϊ32λ�ľ���
rgb2=bitor(bitshift(uint32(r),16),bitshift(uint32(g),8));
rgb2=bitor(rgb2,uint32(b));%���л����㣬������ֵ����������
fid0 = fopen('image_gray.coe','wt');
fprintf(fid0,'MEMORY_INITIALIZATION_RADIX=16;\n');
fprintf(fid0,'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(fid0, '%02x,\n', rgb2');%��������6λ16��������������0ռλ
fid0 = fclose(fid0);%�ر�����ļ�

zero=zeros(256,256);%�����ʾ����
R=cat(3,r,zero,zero);%R����ͼ��
G=cat(3,zero,g,zero);
B=cat(3,zero,zero,b);
RGB=cat(3,r,g,b);%ԭʼͼ��
%��ʾͼ��
subplot(2,2,1),imshow(R),title('��ɫ����');
subplot(2,2,2),imshow(G),title('��ɫ����');
subplot(2,2,3),imshow(B),title('��ɫ����');
subplot(2,2,4),imshow(RGB);
