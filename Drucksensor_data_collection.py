import serial
import datetime
import os.path

portNumber = "COM4"
baudRate = 57600
# this should be identified with the baud rate setting in Arduino

file_saved_path = 'C:\\Messkonzept\\Drucksensordata\\'

port_found = [False]
# when the port was found，it turns True.

data = ['']
# array to store the data

def port_connection (portNumber,baudRrate):
    #confirm the port was found

    try:
        serialArduino = serial.Serial(portNumber, baudRate)
        #setup Arduino Portnumber and Baudrate

        port_found[0] = True
        print("The port was found?"+str(serialArduino.isOpen()))
        print("Please press (Ctrl + C) to stop recording and save data!")
        return serialArduino
    except IOError:
        print("Can not find port:"+portNumber)
        print("Please confirm the portnumber")


def readData(serialArduino):
    count=0
    #count the data
    
    try:
        while port_found[0]:
            
            valueRead = serialArduino.readline(500)
            #read the data from port
            
            #inputData(valueRead)
            #calibrate the sensor value
            
            currentTime = datetime.datetime.now().strftime("%H %M %S.%f")
            #current time of computer
            
            valuewithtime = str(currentTime) + " " + valueRead.decode("utf8")[:-1]
            #[:-1] is to delete /n. This make the data look cleaner
            
            #print(valuewithtime)

            if ("Load_cell" in str(valuewithtime)):
                #only record the data of interest
                valuewithtime = valuewithtime[:16]+valuewithtime[25:]
                #print(valuewithtime)
                #valuewithtime = valuewithtime.replace(":"," ")
                data[0]=data[0]+valuewithtime
                #continuously store the data into an array
                count=count+1
                #count the number of data
                
            if(count%100==0 and count!=0):
                #save data every 100 times
                print(count)
                saveData(data)
                    
    except KeyboardInterrupt:
        print("Recording stopped.")
        saveData(data)

def inputData(valueRead):
    
    if("Send 't' from serial monitor to set the tare offset." in str(valueRead)):
        content = 't'
        content = bytes(content, encoding = "utf8")
        serialArduino.write(content)

    if("Then send the weight of this mass (i.e. 100.0) from serial monitor." in str(valueRead)):
        content = input("Then send the weight of this mass (i.e. 100.0) from serial monitor.")
        content = bytes(content, encoding = "utf8")
        serialArduino.write(content)
    if("Save this value to EEPROM adress 0? y/n" in str(valueRead)):
        content = 'y'
        content = bytes(content, encoding = "utf8")
        serialArduino.write(content)
                
def saveData(data):
    
    with open(file_saved_path, 'a') as f:
        f.write(data[0])
        data[0]=''
        print("data saved!")
            
                    
#if __name__ == "__main__":
    
for i in range(1,99):
    txt_name = "Drucksensor_"+str(i)+".txt"
    file_saved_path = 'C:\\Messkonzept\\Drucksensordata\\'
    if(not (os.path.isfile(file_saved_path+txt_name))):
        file_saved_path = file_saved_path+txt_name
        break
    #if file doesn't exist,then break
serialArduino = port_connection(portNumber,baudRate)
readData(serialArduino)
