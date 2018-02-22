import serial
port = serial.Serial("/dev/ttyS0",baudrate=115200, timeout=5.0)

def remove_leading_zeroes(s):
	i = 0
	while i < len(s) and s[i] == "0":
		i += 1
	return s[i:] 

def get_signature(rcv, signature_length):
	if rcv:
		signatures = ''.join([format(ord(byte), "#04x")[2:][::-1] for byte in rcv])
		for signature in signatures.split('ff'*6):
			if len(signature) == signature_length:
				return signature[::-1]
	return None

signature_length = 20
signature = ""
last_signature = "0" * signature_length
print("### Capturing data from FPGA ###\n")
while True:
	rcv = port.read(signature_length*2 + 12*3)
	signature = get_signature(rcv, signature_length)
	if signature and signature != last_signature:
		print("### Data sent from FPGA is ###")
		print(remove_leading_zeroes(signature))
		print("### End of data sent from FPGA ###\n")
	last_signature = signature
