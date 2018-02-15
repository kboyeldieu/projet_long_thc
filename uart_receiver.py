import serial
port = serial.Serial("/dev/ttyS0",baudrate=115200, timeout=3.0)
a = ""
cpt_0 = 0

while True:
	rcv = port.read(1)
	# print(ord(rcv),cpt_0)
	if ord(rcv) == 0:
		if cpt_0 == 3:
			cpt_0 = 1
		else :
			cpt_0 += 1
		if a:
			print(a[::-1])
			a = ""
	else:
		if cpt_0 == 3 :
			a += hex(ord(rcv))[2:][::-1]
		else :
			cpt_0 = 0
