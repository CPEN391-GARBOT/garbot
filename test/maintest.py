from time import sleep
from ctypes import *

#connect to the C file
garbot = CDLL("./gar_bot.so")

#test connection
garbot.connect()

#test sdram transfers, make sure weights.bin and garbage.bin exist in /Garbot folder
resultphoto = garbot.load_photo()
resultweights = garbot.load_weights()

print(str(resultphoto) + str(resultweights))

first_photo_bytes = garbot.read_sdram(0x00500000)
first_weight_bytes = garbot.read_sdram(0)

print(str(first_photo_bytes))
print(str(first_weights_bytes))

#test buttons
button = garbot.wait_on_buttons()
print(str(button))

#test leds
garbot.turn_leds_on()
sleep(2)
garbot.turn_leds_off()
