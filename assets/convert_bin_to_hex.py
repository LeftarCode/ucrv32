import sys

def bin_to_hex_array(bin_filename):
    with open(bin_filename, "rb") as f:
        data = f.read()
    if len(data) % 4 != 0:
        raise ValueError("File size is not a multiple of 4 bytes.")
    hex_array = []
    for i in range(0, len(data)):
        word = data[i]
        hex_str = f"{word:02X}"
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
    
    file0 = open("instr.bin", "w")
    for hex_str in hex_array:
        file0.write(hex_str + "\n")

if __name__ == "__main__":
    main()
