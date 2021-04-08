import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BCM)

gServo = GPIO.setup(12, GPIO.OUT)
gMotor = GPIO.PWM(12, 50)
cServo = GPIO.setup(13, GPIO.OUT)
cMotor = GPIO.PWM(13, 50)
plServo = GPIO.setup(6, GPIO.OUT)
plMotor = GPIO.PWM(6, 50)
paServo = GPIO.setup(5, GPIO.OUT)
paMotor = GPIO.PWM(5, 50)

gMotor.start(0)
cMotor.start(7.5)
plMotor.start(7.5)
paMotor.start(7.5)
sleep(10)

gMotor.ChangeDutyCycle(5)
sleep(1)
gMotor.ChangeDutyCycle(0)
cMotor.ChangeDutyCycle(5)
sleep(1)
plMotor.ChangeDutyCycle(5)
sleep(1)
paMotor.ChangeDutyCycle(5)
sleep(1)

gMotor.stop()
cMotor.stop()
plMotor.stop()
paMotor.stop()

GPIO.cleanup()
