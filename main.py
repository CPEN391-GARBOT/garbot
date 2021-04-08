import os
from time import sleep
from ctypes import *

#connect to the C file
garbot = CDLL("./gar_bot.so")

#call C function to check connection
garbot.connect()

def main():
  photo_err = 1; #test for change in variable
  #Load the weights into memory
  weights_err = garbot.load_weights()
  if weights_err == -1:
      print("error loading weights")
  #Check if the photo has been sent
  while True:
    if os.path.exists('./Photo/leds.txt'):
        #transfer the photo to sdram
      photo_err = garbot.load_photo()
      if photo_err == -1 or photo_err == 1:
          print('error loading photo into mem')
          break
      #start the ML
      accelerator_result = garbot.start_accelerators()
      if accelerator_result == -1:
          print('error with hardware acceleration')
      else:
          print("1-"+str(accelerator_result))
          #add the stat to the GUI by printing through the pipe
          print(accelerator_result)
          #send_wifi_response(accelerator_result)


      os.remove('./Photo/garbage.bin')
      print("File removed")
