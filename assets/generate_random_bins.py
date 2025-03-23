

hexes = []
for i in range(16):
    hexes.append('%08X' % i)

file0 = open("rand0.bin", "w")
file1 = open("rand1.bin", "w")
file2 = open("rand2.bin", "w")
file3 = open("rand3.bin", "w")

for hex_str in hexes:
    hex1 = hex_str[0:2]
    hex2 = hex_str[2:4]
    hex3 = hex_str[4:6]
    hex4 = hex_str[6:8]
    file0.write(hex4 + "\n")
    file1.write(hex3 + "\n")
    file2.write(hex2 + "\n")
    file3.write(hex1 + "\n")