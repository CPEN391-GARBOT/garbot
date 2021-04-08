import numpy as np
import argparse
import imutils
import cv2

from time import sleep
from imutils.video import VideoStream
from imutils.video import FPS

ap = argparse.ArgumentParser()
ap.add_argument("-p","--prototxt", required=True,
    help="path to Caffee 'deploy' prototxt file")
ap.add_argument("-m","--model", required=True,
    help="path to Caffee pre-trained model")
ap.add_argument("-c", "--confidence", type=float,
    default=0.2, help="minimum probability to filter weak detections")
args = vars(ap.parse_args())

CLASSES = ["background","aeroplane","bicycle","bird","boat","bottle","bus","car","cat","chair","cow","diningtable",
           "dog","horse","motorbike","person","pottedplant","sheep","sofa","train","tvmonitor"]
COLOURS = np.random.uniform(0,255, size=(len(CLASSES), 3))

print("[INFO] loading model...")
net = cv2.dnn.readNetFromCaffe(args["prototxt"], args["model"])

print("[INFO] starting video stream...")
vs = VideoStream(usePiCamera=True).start()
sleep(2.0)
fps = FPS().start()

while True:
    frame = vs.read()
    frame = imutils.resize(frame, width=400)
    
    (h,w) = frame.shape[:2]
    blob = cv2.dnn.blobFromImage(cv2.resize(frame, (300, 300)),
        0.007843, (300, 300), 127.5)
    
    net.setInput(blob)
    detections = net.forward()
    
    for i in np.arange(0, detections.shape[2]):
        
        confidence = detections[0,0,i,2]
        if confidence > args["confidence"]:
            print(confidence)
            idx = int(detections[0,0,i,1])
            box = detections[0,0,i,3:7] * np.array([w,h,w,h])
            (startX, startY, endX, endY) = box.astype("int")
            
            label = "{}: {:.2f}%".format(CLASSES[idx], confidence * 100)
            cv2.rectangle(frame, (startX, startY), (endX, endY), COLOURS[idx], 2)
            cv2.putText(frame, label, (startX, startY - 15), cv2.FONT_HERSHEY_SIMPLEX, .5, COLOURS[idx], 2)
    cv2.imshow("Frame", frame)
    key  = cv2.waitKey(1) & 0xFF
            
    if key == ord("q"):
        break
        
    fps.update()
        
fps.stop()
print("[INFO] elapsed time: {:2f}".format(fps.elapsed()))
print("[INFO] approx. FPS: {:.2f}".format(fps.fps()))
    
cv2.destroyAllWindows()
vs.stop()