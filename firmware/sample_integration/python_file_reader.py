import os
import cv2

import numpy as np
from fxpmath import Fxp

IMG_SIZE = 128

def load_file():
    path = "./download.jpg"

    #XxYx3 bgr image
    img_array = cv2.imread(path, cv2.IMREAD_COLOR)

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


    for pixel in flat_array:
        abs_bin = Fxp(abs(pixel), signed=False, n_word=31, n_frac=24)
        
        if pixel >= 0:
            sign_extended = "0" + abs_bin.bin()
        else:
            sign_extended = "1" + abs_bin.bin()
            
        with open("photo.bin", "ab") as myfile:
            n = int(sign_extended, 2)
            data = n.to_bytes(4, "big")
            myfile.write(data)



    

load_file()
