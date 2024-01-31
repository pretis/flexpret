#!/usr/bin/python3

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input", help="Input memory file")
parser.add_argument("output", help="Output serialized app")

args = parser.parse_args()

DBG=False


def DBG_PRINT(str):
    if DBG:
        print(str)

SYNC_ID = 0xC0DE

print("Running serialize_app.py")

with open(args.input, "r") as fr:
    lines = fr.readlines()
    DBG_PRINT(f"Got {len(lines)} lines")
    length = len(lines) * 4
    lengthField = length.to_bytes(2, "little")
    DBG_PRINT(f"lengthField={lengthField}")

    with open(args.output, "wb") as fw:
        syncField = SYNC_ID.to_bytes(2, "little")
        DBG_PRINT(f"SyncField={syncField}")
        fw.write(syncField)
        fw.write(lengthField)

        for l in lines:
            DBG_PRINT(f"Line={l} hex_string={bytearray.fromhex(l)}")
            bs = bytes.fromhex(l)
            if len(bs) < 4:
                while len(bs) < 4:
                    bs = bytes.fromhex("00") + bs
            
            assert(len(bs) == 4)
            fw.write(bs)
        fw.write(syncField)
        

print("serialize_app.py Done")