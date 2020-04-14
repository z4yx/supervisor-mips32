#!/usr/bin/env python3
# -*- encoding=utf-8 -*-
import numpy as np

# addr = 0x80400000
# length = 128*128*4
n = 96
z = np.zeros((128,128), dtype=np.int32)
a = z.copy()
a[:n, :n] = np.random.randint(-1000, 1000, size=(n,n))
b = z.copy()
b[:n, :n] = np.random.randint(-1000, 1000, size=(n,n))
c = a @ b
print(a)
print(b)
print(c)

def printHex(f, i):
    if i < 0:
        i += 0x100000000
    f.write(f"{i:08x}\n")

with open("matrix.in", "w") as f:
    # addr += 16
    # printHex(f, addr) # address of a
    # printHex(f, addr+length) # address of b
    # printHex(f, addr+length*2) # address of c
    # printHex(f, n)
    # value of a
    for row in a:
        for col in row:
            printHex(f, col)
    # value of b
    for row in b:
        for col in row:
            printHex(f, col)
    # initial value of c (all zeros)
    for row in z:
        for col in row:
            printHex(f, col)
with open("matrix.out", "w") as f:
    # value of c
    for row in c:
        for col in row:
            printHex(f, col)
