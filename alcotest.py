import time
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn

# Calibration - value in clean air
BASELINE_VOLTAGE = 1.4
i2c = busio.I2C(board.SCL, board.SDA)
ads = ADS.ADS1115(i2c)
chan = AnalogIn(ads, 0)

def voltage_to_bac(voltage):
    if voltage < BASELINE_VOLTAGE * 1.2:
        return 0.0
    #Linear interpolation between baseline and max
    ratio = (voltage - BASELINE_VOLTAGE) / (3.8 - BASELINE_VOLTAGE)
    bac = ratio * 2.0 # max ~ 2.0

    return round(bac, 3)
    
print ("Alkotestr zapushen dujte v sensor")
print("-" * 40)

while True:
    voltage = chan.voltage
    bac = voltage_to_bac(voltage)
    print(f"napriazenije: {voltage:.3f}V | BAC: {bac} ")
    time.sleep(1)
