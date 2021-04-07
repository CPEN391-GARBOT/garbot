#!/usr/bin/env python
# coding: utf-8

import numpy as np
import matplotlib.pyplot as plt
import os
import cv2
import random

DATADIR = "./dataset-resized"
CATEGORIES = ["cardboard", "glass", "metal", "paper", "plastic", "trash", "compost"]

training_data = []

IMG_SIZE = 128

def create_training_data():
    for category in CATEGORIES:
        path = os.path.join(DATADIR, category) #path to all types of images

        class_num = CATEGORIES.index(category)
        
        if class_num == 0:
            one_hot = [1., 0., 0., 0., 0., 0., 0.]
        elif class_num == 1:
            one_hot = [0., 1., 0., 0., 0., 0., 0.]
        elif class_num == 2:
            one_hot = [0., 0., 1., 0., 0., 0., 0.]
        elif class_num == 3:
            one_hot = [0., 0., 0., 1., 0., 0., 0.]
        elif class_num == 4:
            one_hot = [0., 0., 0., 0., 1., 0., 0.]
        elif class_num == 5:
            one_hot = [0., 0., 0., 0., 0., 1., 0.]
        else:
            one_hot = [0., 0., 0., 0., 0., 0., 1.]

        for img in os.listdir(path):
            img_array = cv2.imread(os.path.join(path, img), cv2.IMREAD_COLOR)
            #img_array = cv2.imread(os.path.join(path, img), cv2.IMREAD_GRAYSCALE)

            im = img_array.copy()
            im[:, :, 0] = img_array[:, :, 2]
            im[:, :, 2] = img_array[:, :, 0]
            
            new_array = cv2.resize(im, (IMG_SIZE, IMG_SIZE))

            training_data.append([new_array, one_hot])
        
        

create_training_data()
random.shuffle(training_data) #randomize data to decrease bias

plt.imshow(training_data[0][0])


X = [] #feature set
y = [] #labels

for features, label in training_data:
    X.append(features)
    y.append(label)
    
X = np.array(X).reshape(-1, IMG_SIZE, IMG_SIZE, 3) #Each photo is a 128x128 image with 3 channels representing rgb, keras needs a np array

X = X / 255.0

np.save('features.npy', X)
np.save('labels.npy', y)

X = np.load('features.npy')
y = np.load('labels.npy')

