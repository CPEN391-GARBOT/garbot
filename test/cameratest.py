# File contains all functions for camera
from picamera import PiCamera
from time import sleep
from PIL import Image

camera = PiCamera()
camera.resolution = (600,600)

def take_picture(name):
    camera.capture('/home/pi/Desktop/image.jpg')
    path = "/home/pi/Desktop/image.jpg"
    file = Image.open(path)
    new_file = file.resize((128,128))
    new_file.save('/home/pi/Desktop/image1.jpg')
    # with remote access, you cannot see the picture !!!!!!

try:
    print("Hi, I am ready to run......")
    start = take_picture("tst")

finally:
    print("done")


