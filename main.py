import os
import shutil
from time import sleep
from ctypes import *

#connect to the C file
garbot = CDLL("./gar_bot.so")

#call C function to check connection
garbot.connect()

def main():
  #Load the weights into memory
  weights_err = garbot.load_weights()
  if weights_err == -1:
      print("error loading weights")
  #Check if the photo has been sent
  while True:
    if os.path.exists("one.txt"):
      os.remove("one.txt")
  #    print("removed one")
    if os.path.exists("two.txt"):
      os.remove("two.txt")
  #    print("removed two")
    if os.path.exists("three.txt"):
      os.remove("three.txt")
  #    print("removed three")
    if os.path.exists("four.txt"):
      os.remove("four.txt")
  #    print("removed four")

    if os.path.exists('./garbage.bin'):
        #transfer the photo to sdram
      photo_err = garbot.load_photo()
      if photo_err == -1:
          print('error loading photo into mem')
          break
      #start the ML
      accelerator_result = garbot.start_accelerators()
      if accelerator_result == -1:
          print('error with hardware acceleration')
      else:
          print("1-"+str(accelerator_result))
          #add the stat to the GUI by printing through the pipe
          button = garbot.wait_on_buttons();
	  print("2-"+str(button))
	  if (button == 1):
		os.mknod("one.txt")
	  elif (button == 2):
		os.mknod("two.txt")
	  elif (button == 3):
		os.mknod("three.txt")
	  elif (button == 4):
	 	os.mknod("four.txt")
	  sleep(7)
	  os.remove('garbage.bin')
  #    print("File removed")
main()
