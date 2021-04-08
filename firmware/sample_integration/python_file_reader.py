import os
import cv2

import numpy as np

IMG_SIZE = 128

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


def load_file():
    path = "./download.jpg"

    #XxYx3 bgr image
    img_array = cv2.imread(path, cv2.IMREAD_COLOR)

    print(len(img_array))

    #XxYx3 rgb image
    im = img_array.copy()
    im[:, :, 0] = img_array[:, :, 2]
    im[:, :, 2] = img_array[:, :, 0]

    #128x128x3 rgb image    
    new_array = cv2.resize(im, (IMG_SIZE, IMG_SIZE))
    #formatted_array = cv2.resize(im, (IMG_SIZE, IMG_SIZE))

    #3x128x128 rgb image and linearized
    formatted_array = np.transpose(new_array, (2, 0, 1))
    formatted_array = formatted_array / 255.0

    flat_array = formatted_array.flatten()

    print(len(flat_array))


    with open("photo.bin", "ab") as myfile:
        for pixel in flat_array:
            test = float_bin(abs(pixel), 24)
            if pixel >= 0:
                sign_extended = "0" + test
            else:
                sign_extended = "1" + test
                
            n = int(sign_extended, 2)
            data = n.to_bytes(4, "big")
            myfile.write(data)


load_file()
