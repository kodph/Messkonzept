import os

path = "C:\\Messkonzept\\Lidarsensordata\\BW_TFDS_x86_V1.4.0_20200911_Beta\Data\\"
file_saved_path = "C:\\Messkonzept\\Lidarsensordata\\Lidar_matlab\\"
i = 0

for root, dirs, files in os.walk(path):
    
    # read all files in path
    for file in files:
        with open(path + file) as f:
            data = ""
            line = f.readline()
            
            # The original file have some errors, for instance, timestamp 11:36:005 will turn 11:36:5. Next command can add 0 and 00 at proper position
            while (line):
                a = line.split(".")
                if (len(a) > 1):
                    a[0] = a[0].replace(":", " ")
                    a[1] = a[1].replace(" ", "")
                    if (len(a[1]) == 3):
                        a[1] = "0" + a[1]
                    if (len(a[1]) == 2):
                        a[1] = "00" + a[1]
                    a[1] = "." + a[1]
                    data = data + a[0] + a[1]
                line = f.readline()
                
        # restore all files and rename them as Lidarsensor_1, Lidarsensor_2, Lidarsensor_3...
        i = i + 1
        file_saved_path = "C:\\Messkonzept\\Lidarsensordata\\Lidar_matlab\\" + "Lidarsensor_" + str(i) + ".txt"

        with open(file_saved_path, 'w') as s:
            s.write(data)
