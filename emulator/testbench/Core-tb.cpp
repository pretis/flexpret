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
#ifdef FLEXPRET
    uint32_t h_e = 1, f_s = 1, f_e = 1;
#else
    uint32_t h_e = 1, f_s = THREADS, f_e = THREADS;
#endif
    int sweep = 0;
    int trace = 0;

    // Parse command line options.
    int current_option;
    int option_index = 0;
    static struct option long_options[] = {
        {"sweep", no_argument, &sweep, 1},
        {"trace", no_argument, &trace, 1}, // Text trace.
        {"maxcycles", required_argument, 0, 'm'},
        {"ispm", required_argument, 0, 'i'},
        {"dspm", required_argument, 0, 'd'},
        {"vcd",  optional_argument, 0, 'v'}, // VCD file.
        {"vcdstart",  optional_argument, 0, 's'}, // VCD start cycle.
        {0, 0, 0, 0}
    };


    while((current_option = getopt_long(argc, argv, "i:d:vs", long_options, &option_index)) != -1) {
        switch(current_option) {
            case 0:
                break;
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
            default:
                return -1;
        }
    }

    if(sweep) {
        h_e = THREADS;
#ifdef FLEXPRET
        f_e = 8;
#endif
        printf("sweep\n");
    }

    // Open VCD trace dump file (if enabled).
    if(vcd) {
        vcd_file = fopen(vcd_filename, "w");
    }

    // Iterate through test configurations
    char msg[22];
    msg[0] = '\0';
    for(uint32_t h = 0; h < h_e; h++) {
        for(uint32_t f = f_s; f <= f_e; f++) {

            // For PASSED/FAILED
            if(sweep) {
                sprintf(msg, "(tid = %d, f = 1/%d) ", h, f);
            }
    
            // Instantiate and initialize top level Chisel module 'Core'.
            // TODO: move new outside loop?
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

            // Initialize hardware thread scheduling
            // Set only active thread as h
            c->Core_datapath_csr__reg_tmodes_0 = LIT<4>(h != 0);
#if THREADS>1
            c->Core_datapath_csr__reg_tmodes_1 = LIT<4>(h != 1);
            c->Core_datapath_csr__reg_tmodes_2 = LIT<4>(h != 2);
            c->Core_datapath_csr__reg_tmodes_3 = LIT<4>(h != 3);
#endif
#if THREADS>4
            c->Core_datapath_csr__reg_tmodes_4 = LIT<4>(h != 4);
            c->Core_datapath_csr__reg_tmodes_5 = LIT<4>(h != 5);
            c->Core_datapath_csr__reg_tmodes_6 = LIT<4>(h != 6);
            c->Core_datapath_csr__reg_tmodes_7 = LIT<4>(h != 7);
#endif
#ifdef FLEXPRET
            // Active thread in slot 0
            c->Core_datapath_csr__reg_slots_0 = LIT<4>(h);
            // Use SRTT (14) or disabled (15) slot values to achieve f.
            c->Core_datapath_csr__reg_slots_1 = LIT<4>((f > 1) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_2 = LIT<4>((f > 2) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_3 = LIT<4>((f > 3) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_4 = LIT<4>((f > 4) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_5 = LIT<4>((f > 5) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_6 = LIT<4>((f > 6) ? 14 : 15);
            c->Core_datapath_csr__reg_slots_7 = LIT<4>((f > 7) ? 14 : 15);
#endif


            // I/O pins
            uint32_t tohost;
            uint32_t tohost_prev = 0;
            uint32_t gpio[4] = {0,0,0,0};
            uint32_t gpio_prev[4] = {0,0,0,0};

            // Thread timing behavior without timing instructions
            struct counters_t {
                bool if_valid, dec_valid;
                uint8_t if_tid, dec_tid;
                uint64_t processor_cycles[4];
                uint64_t thread_cycles[4];
                uint64_t commit_cycles[4];
            } counter;
            for(int i = 0; i < 4; i++) {
                counter.processor_cycles[i] = 0;
                counter.thread_cycles[i] = 0;
                counter.commit_cycles[i] = 0;
            }

            // Simulate processor until termination signal or max cycles reached
            done = false;
            while(!done && (max_cycles == 0 || cycle < max_cycles)) {

                // Setup inputs.

                // Signals from program to trigger emulator behavior.
                // Hack to trigger external interrupt (w/ csrr a0, frm)
                if(c->Core_datapath__dec_reg_inst.lo_word() == 0x00202573) {
                    c->Core__io_int_exts_0 = LIT<1>(1);
                } else {
                    c->Core__io_int_exts_0 = LIT<1>(0);
                }
        
                
                // Check outputs.
                c->clock_lo(LIT<1>(0));
        
                // TODO: add stats

                // Currently assume all peripheral bus writes are characters
                //if(c->Core__io_bus_enable.to_bool() && c->Core__io_bus_write.to_bool() && ((c->Core__io_bus_addr.lo_word() & ) == 0x...)) {
                if(c->Core__io_bus_enable.to_bool() && c->Core__io_bus_write.to_bool()) {
                    printf("%c", c->Core__io_bus_data_in.lo_word());
                }

                // Monitor GPIO
                gpio[0] = c->Core__io_gpio_out_0.lo_word();
                gpio[1] = c->Core__io_gpio_out_1.lo_word();
                gpio[2] = c->Core__io_gpio_out_2.lo_word();
                gpio[3] = c->Core__io_gpio_out_3.lo_word();
                for(int i = 0; i < 4; i++) {
                    if(gpio[i] != gpio_prev[i]) {
                       printf("GPIO (tid = %d, cycle = %7d): 0x%08x\n", i, cycle, gpio[i]);
                    }
                    gpio_prev[i] = gpio[i];
                }
        
                // Monitor to_host
                tohost = c->Core__io_host_to_host.lo_word();
                if(tohost != tohost_prev) {
                    if(tohost == 1) {
                        printf("*** PASSED %s***\n", msg);
                        done = true;
                    }
                    if(tohost > 1) {
                        printf("*** FAILED %s***(test #%d)\n", msg, tohost);
                        fail = true;
                        done = true;
                    }
                }
                tohost_prev = tohost;
    
                // Keep track of scheduling decision until execute stage
                bool exe_valid = counter.dec_valid;
                uint8_t exe_tid = counter.dec_tid;
                counter.dec_valid = counter.if_valid;
                counter.dec_tid = counter.if_tid;
                counter.if_valid = c->Core_control__if_reg_valid.to_bool();
                counter.if_tid = c->Core_datapath__if_reg_tid.lo_word();
                // Print counter for thread
                if(c->Core_datapath_csr__io_rw_write.to_bool() && c->Core_datapath_csr__io_rw_addr.lo_word() == 0xCCF) {
                    printf("cycle %llu:\t, tid = %d\t, proc_cycles = %llu\t, thread_cycles = %llu\t, commit_cycles = %llu\n", cycle, exe_tid, counter.processor_cycles[exe_tid], counter.thread_cycles[exe_tid], counter.commit_cycles[exe_tid]);
                    //printf("Counters for tid = %d\n", exe_tid);
                    //printf("Processor cycles = %llu\n", counter.processor_cycles[exe_tid]);
                    //printf("Thread cycles = %llu\n", counter.thread_cycles[exe_tid]);
                    //printf("Commit cycles = %llu\n", counter.commit_cycles[exe_tid]);
                }

                // Update counters at commit point in execute stage
                for(int i = 0; i < 4; i++) {
                    counter.processor_cycles[i]++;
                }
                counter.thread_cycles[exe_tid]++;
                if(c->Core_control__exe_valid.to_bool()) {
                    counter.commit_cycles[exe_tid]++;
                }
                // Reset counter for thread
                if(c->Core_datapath_csr__io_rw_write.to_bool() && c->Core_datapath_csr__io_rw_addr.lo_word() == 0xCCE) {
                    counter.processor_cycles[exe_tid] = 0;
                    counter.thread_cycles[exe_tid] = 0;
                    counter.commit_cycles[exe_tid] = 0;
                }

                // Output cycle to vcd
                if(vcd && cycle >= vcd_start) {
                    c->dump(vcd_file, cycle);
                }

                // Text trace
                if(trace) {
                    printf("Trace: cycle = %d\t, tid=%d\t, valid=%d\t, pc=%016x\n", cycle, c->Core_datapath__exe_reg_tid.lo_word(), c->Core_control__exe_valid.lo_word(), c->Core_datapath__exe_reg_pc.lo_word());
                    // spike
                    //if(c->Core_control__exe_valid.to_bool()) {
                    //    printf("%5d\t: 0x%016x\n",counter.commit_cycles[exe_tid],c->Core_datapath__exe_reg_pc.lo_word());
                    //    //printf("0x%016x\n",c->Core_datapath__exe_reg_pc.lo_word());
                    //}
                }

                // Next cycle
                c->clock_hi(LIT<1>(0));
                cycle++;
            }

            // Check for timeout
            if(cycle >= max_cycles) {
                printf("*** FAILED ***(Max cycles timeout)\n");
                fail = true;
            }

            // Print out stats
            //for(int i = 0; i < 4; i++) {
            //    printf("Counters for tid = %d\n", i);
            //    printf("Processor cycles = %llu\n", counter.processor_cycles[i]);
            //    printf("Thread cycles = %llu\n", counter.thread_cycles[i]);
            //    printf("Commit cycles = %llu\n", counter.commit_cycles[i]);
            //}
        }
    }

    // Close VCD trace dump file (if enabled).
    if(vcd) {
        fclose(vcd_file);
    }

    return 0;
}

