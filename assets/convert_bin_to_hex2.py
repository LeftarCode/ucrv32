import sys

def bin_to_hex_array(bin_filename):
    with open(bin_filename, "rb") as f:
        data = f.read()
    if len(data) % 4 != 0:
        raise ValueError("File size is not a multiple of 4 bytes.")
    hex_array = []
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4], byteorder='little')
        hex_str = f"{word:08X}"
        hex_array.append(hex_str)
    return hex_array

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <file.bin>")
        sys.exit(1)
    bin_filename = sys.argv[1]
    hex_array = []
    try:
        hex_array = bin_to_hex_array(bin_filename)
    except Exception as e:
        print(f"Error: {e}")
    
    file0 = open("rand0.bin", "w")
    file1 = open("rand1.bin", "w")
    file2 = open("rand2.bin", "w")
    file3 = open("rand3.bin", "w")
    for hex_str in hex_array:
        hex1 = hex_str[0:2]
        hex2 = hex_str[2:4]
        hex3 = hex_str[4:6]
        hex4 = hex_str[6:8]
        file0.write(hex4 + "\n")
        file1.write(hex3 + "\n")
        file2.write(hex2 + "\n")
        file3.write(hex1 + "\n")

if __name__ == "__main__":
    main()
