import serial
port = serial.Serial("/dev/ttyS0",baudrate=115200, timeout=3.0)

def remove_leading_zeroes(s):
	i = 0
	while i < len(s) and s[i] == "0":
		i += 1
	return s[i:] 

res = ""
last_res = ""
cpt_0 = 0
print("### Capturing data from FPGA ###")
while True:
	rcv = port.read(32)
	if rcv:
		signatures = ''.join([format(ord(byte), "#04x")[2:] for byte in rcv])
		for signature in signatures.split('ff'*6):
			if len(signature) == 20:
				print(signature)
				break
		# if ord(rcv) == 255:
		# 	if cpt_0 == 6:
		# 		cpt_0 = 1
		# 	else :
		# 		cpt_0 += 1
		# 	if res:
		# 		if last_res:
		# 			if last_res != res :
		# 				print("### Data sent from FPGA is ###")
		# 				print(remove_leading_zeroes(res[::-1]))
		# 				print("### End of data sent from FPGA ###")
		# 				last_res = res
		# 		else:
		# 			print("### Data sent from FPGA is ###")
		# 			print(remove_leading_zeroes(res[::-1]))
		# 			print("### End of data sent from FPGA ###")
		# 			last_res = res

		# 		res = ""
		# else:
		# 	if cpt_0 == 6 :
		# 		res += format(ord(rcv), "#04x")[2:][::-1]
		# 	else:
		# 		cpt_0 = 0
