import os
import sys
from pathlib import Path

# Check that environment is set up correctly
if os.environ.get('FP_PATH') == None:
    print('Environment not set up, missing FP_PATH')
    exit(1)

if os.environ.get('FP_SDK_PATH') == None:
    print('Environment not set up, missing FP_SDK_PATH')
    exit(1)

if len(sys.argv) != 2:
    print(f'Usage: {sys.argv[0]} <first/second/third>')
    exit(1)

# There are two files of importance: bootloader-first.mem and
# bootloader.mem
# We expect this script to be run three times:
#   1. When none of these files exist; in this case we generate an
#      empty header file
#   2. When only bootloader-first.mem exists; in this case we generate
#      a header file with the size of the bootloader-first.mem
#   3. When both bootloader-first.mem and bootloader.mem exist. In this
#      case we verify that their sizes are equal

sdk_folder = Path(os.environ.get('FP_SDK_PATH'))
bootloader_build = sdk_folder / 'build' / 'bootloader'


if (bootloader_build / 'bootloader-first.mem').is_file():
    bootloader_first_exist = True
else:
    bootloader_first_exist = False

if (bootloader_build / 'bootloader-second.mem').is_file():
    bootloader_exist = True
else:
    bootloader_exist = False

if sys.argv[1] == 'first' and not bootloader_first_exist:
    # First run: Make empty header
    (bootloader_build / 'empty').mkdir(exist_ok=True)
    with open(bootloader_build / 'empty' / 'location.h', 'w') as f:
        f.write('')

elif sys.argv[1] == 'second' and bootloader_first_exist and not bootloader_exist:
    # Second run: Make header with size of first
    path = bootloader_build / 'bootloader-first.mem'
    lines = sum(1 for _ in open(path))

    (bootloader_build / 'actual').mkdir(exist_ok=True)
    with open(bootloader_build / 'actual' / 'location.h', 'w') as f:
        f.write(f'#define APP_LOCATION {4*lines}')

elif sys.argv[1] == 'third' and bootloader_first_exist and bootloader_exist:
    # Third run: Verify
    path_bl_first = bootloader_build / 'bootloader-first.mem'
    path_bl_final = bootloader_build / 'bootloader-second.mem'

    lines_bl_first = sum(1 for _ in open(path_bl_first))
    lines_bl_final = sum(1 for _ in open(path_bl_final))
    if lines_bl_first != lines_bl_final:
        print('Verification failed. Removing bad artifacts.')
        path_bl_first.unlink()
        path_bl_final.unlink()
        exit(1)
    else:
        btl_path = sdk_folder / 'lib' / 'linker' / 'bootloader' / 'use' / 'bootloader.ld'
        file = f"""
/**
* This flexpret core config file is auto-generated, and based on the
* configuration of the compiled bootloader.
*
* Do not edit.
*
*/
BOOTLOADER_SIZE = {4*lines_bl_final};
"""
        with open(btl_path, 'w') as f:
            f.write(file)
else:
    print('Invalid run of script')
    exit(1)

