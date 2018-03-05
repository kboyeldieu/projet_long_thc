print("N = 0x2fa47df91c352f3112cbL")
print("Find P and Q such that P*Q = N")
while(True):
	p = input("Enter your value for P ")
	q = input("Enter your value for Q ")
	if( p*q == 0x2fa47df91c352f3112cb and p != 0x2fa47df91c352f3112cb and q != 0x2fa47df91c352f3112cb) :
		print("Well done, you've broken RSA-CRT")
		break
	else :
		print("try again !")