import socket as s
import struct
import time

CLOCKFREQ     = int(50e6)
UART_BAUDRATE = 9600
CLKS_PER_BAUD = int(CLOCKFREQ / UART_BAUDRATE)

def make_uart_float(pin, value):
    bytevals = list(struct.pack('!f', value))
    
    return make_uart_byte(pin, bytevals[0]) \
         + make_uart_byte(pin, bytevals[1]) \
         + make_uart_byte(pin, bytevals[2]) \
         + make_uart_byte(pin, bytevals[3])

def make_uart_byte(pin, byte):
    def set_pin(highlow):
        return make_pinevent(pin, CLKS_PER_BAUD, highlow)

    # Start bit
    byte_signals = make_pinevent(pin, 2 * CLKS_PER_BAUD, 0)
    
    # Data bits
    for i in range(8):
        byte_signals += set_pin(byte & (1 << i))
    
    # Stop bit
    byte_signals += set_pin(1)
    return byte_signals

def make_pinevent(pin, ncycles, highlow):
    return struct.pack('III', pin, ncycles, highlow)

def connect_to_emulator():
    client = s.socket(s.AF_INET, s.SOCK_STREAM)
    client.connect(('localhost', 8080))

    return client

def transmit(pin, data):
    for d in data:
        client.send(make_uart_float(pin, d))


client = connect_to_emulator()

# Wait for emulator to initilize
time.sleep(2)

UART_PIN_0 = 8
UART_PIN_1 = 9

# Set pins high, which indicates the UART line is idle
client.send(make_pinevent(UART_PIN_0, 0, 1))
client.send(make_pinevent(UART_PIN_1, 0, 1))

# Will read the data in the file into an array named 'data'
with open('data.txt', 'r') as f:
    code = 'data = [' + f.read() + ']'
    exec(code)

time.sleep(1)
transmit(UART_PIN_0, data)
#time.sleep(12)
#transmit(UART_PIN_1, data)
#time.sleep(12)
#transmit(UART_PIN_0, data)
