
from os import path,makedirs
import time
import cv2

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

def video2txt(src_i,src_o,img_flag):

    capture = cv2.VideoCapture(src_i)
    if capture.isOpened():
        # 分辨率-宽度
        width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
        # 分辨率-高度
        height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
        # 总帧数
        frame_counter = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))

        print("分辨率", width, height)
        print("帧总数", frame_counter)

        fd_file=open(src_o,"w+")  # 打开txt文件

        cnt = 0;

        while True:
            ret,img = capture.read() # img 就是一帧图片

            if not ret:
                fd_file.close()
                break # 当获取完最后一帧就结束

            if img_flag == "RGB":  #选择输出类型
                pass
            elif img_flag == "Gray":
                img = cv2.cvtColor(img,cv2.COLOR_RGB2GRAY)
            else:
                print("ERROR 未知模式")
                return 0

            cv2.imshow("Preview", img_resize(img))
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

            cnt = cnt + 1;
            time_start=time.time()

            if img_flag == "RGB":
                for i in range(height):
                    for j in range(width):
                        print("%02X"%(img[i][j][0])
                            +"%02X"%(img[i][j][1])
                            +"%02X"%(img[i][j][2]),
                            file=fd_file)

            elif img_flag == "Gray":
                for i in range(height):
                    for j in range(width):
                        print("%02X"%(img[i][j]), file=fd_file)

            time_end=time.time()
            print("第%d帧计算耗时:%fs" % (cnt, time_end-time_start))

    else:
        print('视频打开失败！')



if(__name__=="__main__"):

    src_in = "video_i/"+str(input("video_i内视频名:"))
    src_out = "txt_i/"+str(input("输出到txt_i的文件名:"))
    flag = input("处理模式RGB/Gray:")

    time_start=time.time()

    print("\n开始计算...")

    video2txt(src_in,src_out,flag)

    print("计算完成...")

    time_end=time.time()

    print("\n[报告信息]\n")
    print("完成计算消耗时间:%fs" % (time_end-time_start))