#!/usr/bin/env python
# coding: utf-8

import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Activation, Flatten, Conv2D, MaxPooling2D

import numpy as np
import matplotlib.pyplot as plt
from fxpmath import Fxp

#load dataset
X = np.load('features.npy')
y = np.load('labels.npy')

#create model
model = Sequential()
model.add(Conv2D(64, (3,3), input_shape = X.shape[1:]))
model.add(Activation("relu"))
model.add(MaxPooling2D(pool_size = (2,2)))

model.add(Conv2D(64, (3,3)))
model.add(Activation("relu"))
model.add(MaxPooling2D(pool_size = (2,2)))

model.add(Conv2D(64, (3,3)))
model.add(Activation("relu"))
model.add(MaxPooling2D(pool_size = (2,2)))

model.add(Flatten())
model.add(Dense(64))
model.add(Activation('relu'))

model.add(Dense(7))
model.add(Activation('softmax'))

model.compile(loss="categorical_crossentropy",
             optimizer="adam",
             metrics=['accuracy'])

model.summary()

model.fit(X, y, batch_size=16, epochs=15, validation_split=0.10)

model.save("garbot_model")

weights_list = model.get_weights()
weights_file = open("weights.txt", "w")
#weights_array represents all weights, flattened, stored as float point values
weights_array = np.array([])

#write floating_point values to weights.txt for comparison
for row in weights_list:
    np.savetxt(weights_file, row.flatten())
    weights_array = np.append(weights_array, row.flatten())
weights_file.close()

#write fixed_point values to weights.bin to be used by hardware accelerators
for weight in weights_array:
    abs_bin = Fxp(abs(weight), signed=False, n_word=31, n_frac=24)
    
    if weight >= 0:
        sign_extended = "0" + abs_bin.bin()
    else:
        sign_extended = "1" + abs_bin.bin()
        
    with open("weights.bin", "ab") as myfile:
        int_equiv = int(sign_extended, 2)
        final_bytes = int_equiv.to_bytes(4, "big")
        myfile.write(data)




