
# Appends /1 or /2 to fastq id lines.  Specify which number to append
# with the 'read_num' property.
#
# Run with pydoop script with:
#    pydoop script -Dread_num=1 --num-reducers 0 -t '' fix_d2_ids.py input_path_read_1 output_path
#    pydoop script -Dread_num=2 --num-reducers 0 -t '' fix_d2_ids.py input_path_read_2 output_path

def mapper(_, input_line, writer, conf):
    template = "%%s/%s" % conf['read_num']
    if input_line[0] == '@' and len(input_line) < 100:
        writer.emit("", template % input_line)
    else:
        writer.emit("", input_line)
