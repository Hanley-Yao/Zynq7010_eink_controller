from os import path,makedirs
import time
import cv2
import numpy as np

def img_resize(image):
    height, width = image.shape[0], image.shape[1]
    # 设置新的图片分辨率框架
    width_new = 800
    height_new = 600
    # 判断图片的长宽比率
    if width / height >= width_new / height_new:
        img_new = cv2.resize(image, (width_new, int(height * width_new / width)))
    else:
        img_new = cv2.resize(image, (int(width * height_new / height), height_new))
    return img_new

def txt2img(src_i,src_o,width,height,frame_cnt,img_flag):

    fd_file = open(src_i)

    if img_flag == "RGB":
        img = np.zeros((height,width,3), np.uint8)
        for f in range(frame_cnt):
            for i in range(height):
                for j in range(width):
                    line = fd_file.readline()
                    img[i][j][0] = int(line[0:2], 16)
                    img[i][j][1] = int(line[2:4], 16)
                    img[i][j][2] = int(line[4:6], 16)
            cv2.imshow("Preview", img_resize(img))
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            cv2.imwrite(src_o+'/frame_%d.png'%(f), img)

    elif img_flag == "Gray":
        img = np.zeros((height,width,1), np.uint8)
        for f in range(frame_cnt):
            for i in range(height):
                for j in range(width):
                    line = fd_file.readline()
                    img[i][j] = int(line, 16)
            cv2.imshow("Preview", img_resize(img))
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            cv2.imwrite(src_o+'/frame_%d.png'%(f), img)

    fd_file.close()

if(__name__=="__main__"):

    src_in = "txt_o/"+str(input("txt_o内文件名:"))
    src_out = "img_o/"+str(input("输出到img_o的文夹名:"))

    makedirs(src_out,exist_ok=True)

    W = int(input("W:"))
    H = int(input("H:"))

    frame_cnt = int(input("包含帧数:"))

    flag = input("处理模式RGB/Gray:")

    time_start=time.time()

    print("\n开始计算...")

    txt2img(src_in,src_out,W,H,frame_cnt,flag)

    print("计算完成...")

    time_end=time.time()

    print("\n[报告信息]\n")
    print("完成计算消耗时间:%fs" % (time_end-time_start))