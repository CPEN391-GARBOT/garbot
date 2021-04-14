######## Webcam Object Detection Using Tensorflow-trained Classifier #########
#
# Author: Evan Juras
# Date: 10/27/19
# Description:
# This program uses a TensorFlow Lite model to perform object detection on a live webcam
# feed. It draws boxes and scores around the objects of interest in each frame from the
# webcam. To improve FPS, the webcam object runs in a separate thread from the main program.
# This script will work with either a Picamera or regular USB webcam.
#
# This code is based off the TensorFlow Lite image classification example at:
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/examples/python/label_image.py
#
# Import packages

#Modified for use for Garbot by Elise Hlady,
#Description: Uses the TensorFlow lite model to perform object detection on the PiCamera,
#Once a person is detected placing trash in front of the camera, a picture is taken,
#the file is converted into a bin file, and then sent to the DE1-SoC to be processed
#To start the program, first activate the virtual environment with
#source tflite1-env/bin/activate
#then run it with
#python3 garbage_detector.py --modeldir=Sample_TFLite_model
#MAKE SURE THE DE1 ETHERNET IS SET UP: ifconfig eth0 169.254.184.14
import os
import argparse
import cv2
import numpy as np
import sys
import time
from threading import Thread
import importlib.util
#imports for bin file transform and transfer
import pysftp
from fxpmath import Fxp
from PIL import Image
import RPi.GPIO as GPIO
import requests

GPIO.setmode(GPIO.BCM)

# Define VideoStream class to handle streaming of video from webcam in separate processing thread
# Source - Adrian Rosebrock, PyImageSearch: https://www.pyimagesearch.com/2015/12/28/increasing-raspberry-pi-fps-with-python-and-opencv/
class VideoStream:
    """Camera object that controls video streaming from the Picamera"""
    def __init__(self,resolution=(640,480),framerate=30):
        # Initialize the PiCamera and the camera image stream
        self.stream = cv2.VideoCapture(0)
        ret = self.stream.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*'MJPG'))
        ret = self.stream.set(3,resolution[0])
        ret = self.stream.set(4,resolution[1])

        # Read first frame from the stream
        (self.grabbed, self.frame) = self.stream.read()

	# Variable to control when the camera is stopped
        self.stopped = False

    def start(self):
	# Start the thread that reads frames from the video stream
        Thread(target=self.update,args=()).start()
        return self

    def update(self):
        # Keep looping indefinitely until the thread is stopped
        while True:
            # If the camera is stopped, stop the thread
            if self.stopped:
                # Close camera resources
                self.stream.release()
                return

            # Otherwise, grab the next frame from the stream
            (self.grabbed, self.frame) = self.stream.read()

    def read(self):
	# Return the most recent frame
        return self.frame

    def stop(self):
	# Indicate that the camera and thread should be stopped
        self.stopped = True

IMG_SIZE = 128

############### RESTful API calls to increase garbage stats ###############
#parameter stats represents what kind of garbage
# stats=1 : garbage
# stats=2 : compost
# stats=3 : paper
# stats=4 : plastic
def inc_stat(stat):
    url = 'http://192.168.1.87:3000/garbage/'
    body = {"username" : "garbot", "quantity" : "1", "timestamp" : "1617858077"}

    if stat == 1:
        requests.post(url + '1', json=body)
    elif stat == 2:
        requests.post(url + '2', json=body)
    elif stat == 3:
        requests.post(url + '3', json=body)
    elif stat == 4:
        requests.post(url + '4', json=body)

###############Helper Functions for the .jpg to .bin file transformation############
# Takes a floating point number and decimal places and returns a binary
# fixed point representation
def float_bin(number, places = 24):

    if number.is_integer() :
        whole = int(number)
        return f'{whole:07b}' + "000000000000000000000000"
    whole, dec = str(number).split(".")

    whole = int(whole)
    dec = int (dec)

    # Convert to 7 bit binary
    res = f'{whole:07b}'

    for x in range(places):
        whole, dec = str((decimal_converter(dec)) * 2).split(".")
        dec = int(dec)
        res += whole

    return res

def decimal_converter(num):
    while num > 1:
        num /= 10
    return num

################# Lid Openers ###################
#These control the servos to open the different bin lids. cMotor is a coninuous servo motor, the rest are simple servos
def open_garb():
    gMotor.ChangeDutyCycle(5)
    time.sleep(7)
    gMotor.ChangeDutyCycle(10)
    gMotor.ChangeDutyCycle(0)

def open_comp():
    cMotor.ChangeDutyCycle(5)
    time.sleep(.1)
    cMotor.ChangeDutyCycle(0)
    time.sleep(7)
    cMotor.ChangeDutyCycle(10)
    time.sleep(.1)
    cMotor.ChangeDutyCycle(0)

def open_pap():
    paMotor.ChangeDutyCycle(5)
    time.sleep(7)
    paMotor.ChangeDutyCycle(10)
    time.sleep(1)
    paMotor.ChangeDutyCycle(0)

def open_plas():
    plMotor.ChangeDutyCycle(5)
    time.sleep(7)
    plMotor.ChangeDutyCycle(10)
    plMotor.ChangeDutyCycle(0)


##################### Load the file function ########################
#This function is called once a picture is taken
#It starts by converting the gabage.jpg file into a garbage.bin file
#Then it sends the garbage.bin file to the DE1-SoC and waits to 'hear' what the result is
#Lastly, it calls the correct functions to
def load_file():
    #start by croping the image to the size of the training data set, then resize to correct resolution for the nerual network
    path = "/home/pi/Desktop/garbage.jpg"
    file = Image.open("/home/pi/Desktop/garbage.jpg")
    new_file = file.crop((160,0,1120,720))
    final_file = new_file.resize((128,128))
    final_file.save('/home/pi/Desktop/garbage.jpg')

    #transform file into a .bin file
    #XxYx3 bgr image
    img_array = cv2.imread(path, cv2.IMREAD_COLOR)

    print(len(img_array))

    #XxYx3 rgb image
    im = img_array.copy()
    im[:, :, 0] = img_array[:, :, 2]
    im[:, :, 2] = img_array[:, :, 0]

    #128x128x3 rgb image
    new_array = cv2.resize(im, (IMG_SIZE, IMG_SIZE))

    #3x128x128 rgb image and linearized
    formatted_array = np.transpose(new_array, (2, 0, 1))
    formatted_array = formatted_array / 255.0

    flat_array = formatted_array.flatten()

    print(len(flat_array))
    #writes to the .bin file
    with open("garbage.bin", "ab") as myfile:
        for pixel in flat_array:
            test = float_bin(abs(pixel), 24)
            if pixel >= 0:
                sign_extended = "0" + test
            else:
                sign_extended = "1" + test

            n = int(sign_extended, 2)
            data = n.to_bytes(4, "big")
            myfile.write(data)


    #send the photo over to the DE1-SoC
    with pysftp.Connection('169.254.184.14', username='root', password='password', port=22) as sftp:
        print("Connection successfully established")
        localpath = '/home/pi/garbot/garbage.bin'
        remotepath = '/home/root/Garbot/garbage.bin'

        sftp.put(localpath, remotepath)

        sftp.cwd('Garbot')
        sentinal = 1
        #coninuously checks to see if a file has appeared on the DE1 signifying which bin to open, call coressponding open and add stat function
        while sentinal == 1:
            if sftp.exists('one.txt'):
                open_garb()
                inc_stat(1)
                sentinal = 0
            if sftp.exists('two.txt'):
                open_comp()
                inc_stat(2)
                sentinal = 0
            if sftp.exists('three.txt'):
                open_pap()
                inc_stat(3)
                sentinal = 0
            if sftp.exists('four.txt'):
                open_plas()
                inc_stat(4)
                sentinal = 0

#start up the servos
gServo = GPIO.setup(5, GPIO.OUT)
gMotor = GPIO.PWM(5, 50)
#the continuous one
cServo = GPIO.setup(6, GPIO.OUT)
cMotor = GPIO.PWM(6, 50)
plServo = GPIO.setup(13, GPIO.OUT)
plMotor = GPIO.PWM(13, 50)
paServo = GPIO.setup(19, GPIO.OUT)
paMotor = GPIO.PWM(19, 50)

gMotor.start(0)
cMotor.start(0)
plMotor.start(0)
paMotor.start(0)

# Define and parse input arguments
parser = argparse.ArgumentParser()
parser.add_argument('--modeldir', help='Folder the .tflite file is located in',
                    required=True)
parser.add_argument('--graph', help='Name of the .tflite file, if different than detect.tflite',
                    default='detect.tflite')
parser.add_argument('--labels', help='Name of the labelmap file, if different than labelmap.txt',
                    default='labelmap.txt')
parser.add_argument('--threshold', help='Minimum confidence threshold for displaying detected objects',
                    default=0.55)
parser.add_argument('--resolution', help='Desired webcam resolution in WxH. If the webcam does not support the resolution entered, errors may occur.',
                    default='1280x720')


args = parser.parse_args()

MODEL_NAME = args.modeldir
GRAPH_NAME = args.graph
LABELMAP_NAME = args.labels
min_conf_threshold = float(args.threshold)
resW, resH = args.resolution.split('x')
imW, imH = int(resW), int(resH)

# Import TensorFlow libraries
# If tflite_runtime is installed, import interpreter from tflite_runtime, else import from regular tensorflow
pkg = importlib.util.find_spec('tflite_runtime')
if pkg:
    from tflite_runtime.interpreter import Interpreter
else:
    from tensorflow.lite.python.interpreter import Interpreter

# Get path to current working directory
CWD_PATH = os.getcwd()

# Path to .tflite file, which contains the model that is used for object detection
PATH_TO_CKPT = os.path.join(CWD_PATH,MODEL_NAME,GRAPH_NAME)

# Path to label map file
PATH_TO_LABELS = os.path.join(CWD_PATH,MODEL_NAME,LABELMAP_NAME)

# Load the label map
with open(PATH_TO_LABELS, 'r') as f:
    labels = [line.strip() for line in f.readlines()]

# Have to do a weird fix for label map if using the COCO "starter model" from
# https://www.tensorflow.org/lite/models/object_detection/overview
# First label is '???', which has to be removed.
if labels[0] == '???':
    del(labels[0])

# Load the Tensorflow Lite model.
interpreter = Interpreter(model_path=PATH_TO_CKPT)

interpreter.allocate_tensors()

# Get model details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
height = input_details[0]['shape'][1]
width = input_details[0]['shape'][2]

floating_model = (input_details[0]['dtype'] == np.float32)

input_mean = 127.5
input_std = 127.5

# Initialize video stream
videostream = VideoStream(resolution=(imW,imH),framerate=30).start()
time.sleep(1)

#for frame1 in camera.capture_continuous(rawCapture, format="bgr",use_video_port=True):
while True:

    # Grab frame from video stream
    frame1 = videostream.read()

    # Acquire frame and resize to expected shape [1xHxWx3]
    frame = frame1.copy()
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    frame_resized = cv2.resize(frame_rgb, (width, height))
    input_data = np.expand_dims(frame_resized, axis=0)

    # Normalize pixel values if using a floating model (i.e. if model is non-quantized)
    if floating_model:
        input_data = (np.float32(input_data) - input_mean) / input_std

    # Perform the actual detection by running the model with the image as input
    interpreter.set_tensor(input_details[0]['index'],input_data)
    interpreter.invoke()

    # Retrieve detection results
    #boxes = interpreter.get_tensor(output_details[0]['index'])[0] # Bounding box coordinates of detected objects
    classes = interpreter.get_tensor(output_details[1]['index'])[0] # Class index of detected objects
    scores = interpreter.get_tensor(output_details[2]['index'])[0] # Confidence of detected objects
    #num = interpreter.get_tensor(output_details[3]['index'])[0]  # Total number of detected objects (inaccurate and not needed)
    captured = False
    count = 0
    # Loop over all detections and identify the detection if confidence is above minimum threshold
    for i in range(len(scores)):
        if ((scores[i] > min_conf_threshold) and (scores[i] <= 1.0)):

            object_name = labels[int(classes[i])] # Look up object name from "labels" array using class index
            #if a person is detected, wait a second for them to place down the garbage, then take a photo and call load_file()
            if not captured and object_name == "person":
                print("Person detected\n")
                time.sleep(2)
                cv2.imwrite('/home/pi/Desktop/garbage.jpg', videostream.read())
                load_file()
                time.sleep(2)
                os.remove('garbage.bin')
                captured = True


    # All the results have been drawn on the frame, so it's time to display it.
    cv2.imshow('Object detector', frame)

    # Press 'q' to quit
    if cv2.waitKey(1) == ord('q'):
        break

# Clean up
cv2.destroyAllWindows()
videostream.stop()
