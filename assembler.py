#*****************************************************************
# AUTHOR: Christopher Nokes
# DESCRIPTION: Generate a VHDL test bench for a developed CPU.
#*****************************************************************

# create a list of values, given a filename with a file
# in the format [KEY]:[VALUE]
def create_dictionary(filename):
    final_list = []
    for line in open(filename, "r"):
        x   =   line.split(":")
        y   =   x[1].split("//")
        final_list+=[[x[0], y[0]]]
    return final_list

# convert a given integer to a binary string.
def to_binary_string(num, digits):
    if num >= 131072:
        return "11111111111111111"
    return str(int(bin(num).replace("0b", "")) + (9 * 10**digits)).split("9")[1]

# Write the header to a given file.
def write_header(file, filename):
    for line in open("text_files/header.txt", "r"):
        # Replace the placeholder name where needed and write the result
        file.write(line.replace("%PHNAME%", filename))
    return

# Write the footer to a given file.
def write_footer(file):
    for line in open("text_files/footer.txt", "r"):
        file.write(line)
    return

if __name__ == "__main__":
    # input and open the compiled file
    filename = input("Enter file name: ")
    input_file = open(filename, "r")
    # create an output file to write to
    output_file = open("output/" + filename.split(".")[0] + ".vhd", "w")
    # line counter, starts at 0
    counter = 0
    # create dictionaries for registers and operations
    operation_dictionary = dict(create_dictionary("text_files/OP_Dictionary.txt"))
    register_dictionary = dict(create_dictionary("text_files/REG_Dictionary.txt"))
    # current comment on a line + whether or not the last line was just a comment
    comment = ""
    previous_was_comment = False

    # write the header
    write_header(output_file, filename.split(".")[0])


    for line in input_file:
        # handle instruction split
        line = line.upper()
        total = line.split(" ")
        # handle comment lines
        if(total[0] == "//"):
            output_file.write("--" + line.split("//")[1])
            previous_was_comment = True
            continue
        # regardless of line purpose, first two registers in assembly are always the first two in machine code
        current_output = operation_dictionary.get(total[0]) + register_dictionary.get(total[1]) + register_dictionary.get(total[2])
        previous_was_comment = False
        # handles immediate vs. register
        if total[0].__contains__("I"):
            current_output += to_binary_string(int(total[3].split("#")[1]), 17)
        else:
            current_output += register_dictionary.get(total[3]) + "0000000000000"

        # handles end-line comments
        if len(line.split("//")) > 1:
            comment = "\t--" + str(line.split("//")[1].replace("\n", ""))
        else:
            comment = ""
        
        # writes the current line to the file
        output_file.write("(\"11\", \"" + to_binary_string(counter, 11) + "\", \"" + current_output + "\"), " + comment + "\n")
        counter+=4
    
    output_file.write("(\"11\", \"" + to_binary_string(counter, 11) + "\", x\"FFFFFFFF\"));\t -- PROGRAM EXIT COMMAND.")
    write_footer(output_file)
