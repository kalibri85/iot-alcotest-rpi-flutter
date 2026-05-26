from flask import Flask, jsonify
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn

app = Flask(__name__)
BASELINE_VOLTAGE = 1.4

i2c = busio.I2C(board.SCL, board.SDA)
ads = ADS.ADS1115(i2c)
chan = AnalogIn(ads, 0)

def voltage_to_bac(voltage):
 if voltage < BASELINE_VOLTAGE * 1.2:
  return 0.0
 ratio = (voltage - BASELINE_VOLTAGE) / (3.8 - BASELINE_VOLTAGE)
 bac = ratio * 2.0
 return round(bac, 3)
@app.route('/bac')
def get_bac():
 voltage = chan.voltage
 bac = voltage_to_bac(voltage)
 return jsonify({"voltage": round(voltage, 3), "bac": bac})

if __name__ == '__main__':
 app.run(host='0.0.0.0', port=5000, debug=True)
