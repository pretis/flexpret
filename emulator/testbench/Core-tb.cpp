/*
Copyright (c) 2013, The Regents of the University of California.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/******************************************************************************
Core-tb.cpp:
  C++ testbench for FlexPRET processor.
Authors: 
  Michael Zimmer (mzimmer@eecs.berkeley.edu)
******************************************************************************/
#include "Core.h"
#include <getopt.h> // For getopt_long().

int main (int argc, char* argv[]) 
{
    
    bool done = false;
    bool fail = false;
    uint64_t cycle = 0;
    uint64_t max_cycles = 0;
    const char *ispm_filename = NULL;
    const char *dspm_filename = NULL;
    bool vcd = false;
    FILE *vcd_file = NULL;
    const char *vcd_filename = "trace.vcd";
    int vcd_start = 0;

    // Parse command line options.
    int current_option;
    int option_index = 0;
    static struct option long_options[] = {
        {"maxcycles", required_argument, 0, 'm'},
        {"ispm", required_argument, 0, 'i'},
        {"dspm", required_argument, 0, 'd'},
        {"vcd",  optional_argument, 0, 'v'}, // VCD file.
        {"vcdstart",  optional_argument, 0, 's'}, // VCD start cycle.
//        {"trace", optional_argument, 0, 't'}, // Text trace.
        //{"x", no_argument, &flag, 1},}
        {0, 0, 0, 0}
    };


    while((current_option = getopt_long(argc, argv, "i:d:vst", long_options, &option_index)) != -1) {
        switch(current_option) {
            case 'm':
                max_cycles = atoi(optarg);
                printf("maxcycles: %ld\n", max_cycles);
                break;
            case 'i':
                ispm_filename = optarg;
                printf("ispm: %s\n", ispm_filename);
                break;
            case 'd':
                dspm_filename = optarg;
                printf("dspm: %s\n", dspm_filename);
                break;
            case 'v':
                vcd = true;
                if(optarg != NULL) {
                  vcd_filename = optarg;
                }
                printf("vcd: %s\n", vcd_filename);
                break;
            case 's':
                if(optarg != NULL) {
                    vcd_start = atoi(optarg);
                    printf("vcdstart: %d\n", vcd_start);
                }
                break;
            //case '?':
            default:
                return -1;
        }
    }

    // Instantiate and initialize top level Chisel module 'Core'.
    Core_t* c = new Core_t();
    c->init();

    // Reset for several cycles.
    for(int i = 0; i < 5; i++) {
      dat_t<1> reset = LIT<1>(1);
      c->clock_lo(reset);
      c->clock_hi(reset);
    }

    // Initialize memories.
    c->Core_imem__ispm.read_hex(ispm_filename);
    c->Core_dmem__dspm.read_hex(dspm_filename);

    // Open VCD trace dump file (if enabled).
    if(vcd) {
        vcd_file = fopen(vcd_filename, "w");
    }

    uint32_t tohost;
    uint32_t tohost_prev = 0;

    while(!done && (max_cycles == 0 || cycle < max_cycles)) {

        // Setup inputs.
        c->clock_lo(LIT<1>(0));
        // Check outputs.
        // TODO: add stats
        
        // FIXME: remove when possible
        // Hack to reset dspm for each test run.
        if(c->Core_datapath__dec_reg_pc.lo_word() == 0x2000048) {
            c->Core_dmem__dspm.read_hex(dspm_filename);
        }
        tohost = c->Core__io_host_to_host.lo_word();
        if(tohost != tohost_prev) {
            switch(tohost >> 30) {
                case 0:
                    if(tohost == 1) {
                        printf("*** PASSED ***\n");
                        done = true;
                    }
                    if(tohost > 1) {
                        printf("*** FAILED ***(test #%d)\n", tohost >> 1);
                        fail = true;
                        done = true;
                    }
                    break;
                case 1:
                        printf("Thread: %d Id: %d ", ((tohost & 0x38000000) >> 27), tohost & 0x7FFFFFF);
                    break;
                case 2:
                        printf("Time (ms): %f\n", ((tohost & 0x3FFFFFFF)-100000)/1000000.0);
                    break;
                case 3:
                        //printf("Cycle Count = %d\n", (tohost & 0x3FFFFFFF));
                    break;
            }
        }
        tohost_prev = tohost;

        if(vcd && cycle >= vcd_start) {
            c->dump(vcd_file, cycle);
        }
        c->clock_hi(LIT<1>(0));
        cycle++;
    }

    if(cycle >= max_cycles) {
        printf("*** FAILED ***(Max cycles timeout)\n");
        fail = true;
    }

    // Close VCD trace dump file (if enabled).
    if(vcd) {
        fclose(vcd_file);
    }

    return 0;
}
