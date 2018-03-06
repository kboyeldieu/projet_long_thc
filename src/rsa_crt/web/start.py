#! /usr/bin/python

import serial
import time
from fractions import gcd
from flask import Flask, request, jsonify, Response, render_template

port = serial.Serial("/dev/ttyS0",baudrate=115200, timeout=1.0)
app = Flask("server")

def _remove_leading_zeroes(s):
    i = 0
    while i < len(s) and s[i] == "0":
        i += 1
    return s[i:] 

def _get_signature(rcv, signature_length):
    if rcv:
        signatures = ''.join([format(ord(byte), "#04x")[2:][::-1] for byte in rcv])
        for signature in signatures.split('ff'*6):
            if len(signature) == signature_length:
                return _remove_leading_zeroes(signature[::-1])
    return None

def _format_if_necessary(x):
    s = str(x)
    if s[-1] == "L":
        return s[:-1]
    return s

@app.route('/', methods = ['GET'])
def root():
    return render_template('tutorial.html')

@app.route('/get_last_signature', methods = ['GET'])
def get_last_signature():
    signature_length = 20
    port.flushInput()
    rcv = port.read(signature_length*2 + 12*3)
    signature = _get_signature(rcv, signature_length)
    if signature:        
        return jsonify("0x" + _format_if_necessary(signature))
    else:
        return jsonify("Aucun calcul encore effectue.")

@app.route('/get-pgcd', methods = ['GET'])
def get_pgcd():
    a = int(request.args.get('a'), 16)
    b = int(request.args.get('b'), 16)
    return jsonify(_format_if_necessary(hex(gcd(a,b))))

@app.route('/arithmetic', methods = ['GET'])
def operation():
    op = request.args.get('op')
    a = int(request.args.get('a'), 16)
    b = int(request.args.get('b'), 16)
    if op == "multiplication":
        return jsonify(_format_if_necessary(hex(a*b)))
    elif op == "addition":
        return jsonify(_format_if_necessary(hex(a+b)))
    elif op == "soustraction":
        return jsonify(_format_if_necessary(hex(a-b)))
    else:
        # division
        return jsonify(_format_if_necessary(hex(a/b)))

@app.route('/check-answer', methods = ['GET'])
def check_answer_tutorial1():
    expected_q = "0x704905c14b"
    expected_p = "0x6c9ee08481"
    answer = set((expected_q, expected_p))
    p = request.args.get('p')
    q = request.args.get('q')
    if set((p,q)) == answer:
        return jsonify(2)
    elif p in answer or q in answer:
        return jsonify(1)
    else:
        return jsonify(0)

if __name__ == '__main__':
    app.run('0.0.0.0')