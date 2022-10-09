
from os import path,makedirs
import time
import cv2

def img2txt(src_i,src_o,img_flag):

    if img_flag == "RGB":  #选择输出类型
        flag = cv2.IMREAD_COLOR
    elif img_flag == "Gray":
        flag = cv2.IMREAD_GRAYSCALE
    else:
        print("ERROR 未知模式")
        return 0

    img = cv2.imread(src_i, flag)  # 打开图片文件

    Xlenth = img.shape[1]
    Ylenth = img.shape[0]

    print("分辨率",img.shape[1],img.shape[0])

    fd_file=open(src_o,"w+")  # 打开txt文件

    if img_flag == "RGB":
        for i in range(Ylenth):
            for j in range(Xlenth):
                print("%02X"%(img[i][j][0])
                    +"%02X"%(img[i][j][1])
                    +"%02X"%(img[i][j][2]),
                    file=fd_file)

    elif img_flag == "Gray":
        for i in range(Ylenth):
            for j in range(Xlenth):
                print("%02X"%(img[i][j]), file=fd_file)

    fd_file.close()

if(__name__=="__main__"):

    src_in = "img_i/"+str(input("img_i内图片名:"))
    src_out = "txt_i/"+str(input("输出到txt_i的文件名:"))
    flag = input("处理模式RGB/Gray:")

    time_start=time.time()

    print("\n开始计算...")

    img2txt(src_in,src_out,flag)

    print("计算完成...")
    time_end=time.time()

    print("\n[报告信息]\n")
    print("完成计算消耗时间:%fs" % (time_end-time_start))