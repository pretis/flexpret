#!/usr/bin/python3.8
import serial
import os
import sys
import time

usb_path = sys.argv[1]
baudrate = int(sys.argv[2])
file = sys.argv[3]
data = None

if sys.platform.startswith('linux') and not os.path.exists(usb_path):
    exit(f"Could not find USB->UART bridge {usb_path}")

with open(file, "rb") as f:
    data = f.read()

try:
    com = serial.Serial(usb_path, baudrate)
except Exception as e:
    print(f"Couldnt open USB-UART bridge ({usb_path}); is it connected?" + str(e))
    exit(1)

time.sleep(0.1)

try:
    com.write(data)
except Exception as e:
    print("Couldnt write app over uart e:" + str(e))
    pass
