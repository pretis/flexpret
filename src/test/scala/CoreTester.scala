/******************************************************************************
File: CoreTester.scala
Description: Testbench for FlexPRET processor.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package Core.test

import Core._
import chisel3.iotesters._

class CoreTester(c: Core, config: FlexpretConfiguration, sweep: Boolean, trace: Boolean, max_cycles: Int, h: Int, f: Int) extends PeekPokeTester(c) {

  import chisel3._

  // For PASSED/FAILED
  val msg = if (sweep) s"(tid = ${h}, f = 1/${f}) " else ""

  val THREADS = config.threads

  /*
              // Initialize memories.
              c->Core_imem__ispm.read_hex(ispm_filename);
              c->Core_dmem__dspm.read_hex(dspm_filename);
*/
  // Initialize hardware thread scheduling
  // Set only active thread as h

  // TODO(edwardw): use Chisel CICL or other aspects
  // The testbench writes to an internal register (or even to registers in general) which is not supported by
  // PeekPokeTester.

  // Debug: hold those registers we set until we're ready for the design to evolve normally
  c.io.reg_tmodes.freeze.foreach { x => poke(x, 1) }
  c.io.reg_tmodes.write.foreach { x => poke(x.valid, 0) }
  c.io.reg_slots.freeze.foreach { x => poke(x, 1) }
  c.io.reg_slots.write.foreach { x => poke(x.valid, 0) }
  c.io.datapath_exe_reg_pc.freeze.foreach { x => poke(x, 1) }
  c.io.datapath_exe_reg_pc.write.foreach { x => poke(x.valid, 0) }


  // Helper function to write a register using our debug signals
  def write_register(v: DebugBundle[chisel3.UInt], index: Int, value: Option[Int]): Unit = {
    value match {
      case Some(r) => {
        poke(v.write(index).valid, 1)
        poke(v.write(index).bits, r)
      }
      case None => poke(v.write(index).valid, 0)
    }
  }

  // Exists mostly due to JVM type erasure on Option[T]
  def write_register_b(v: DebugBundle[chisel3.UInt], index: Int, value: Option[Boolean]): Unit = {
    write_register(v, index, value.map(if (_) 1 else 0))
  }

  def write_register(v: DebugBundle[chisel3.UInt], index: Int, value: Int): Unit = {
    write_register(v, index, Some(value))
  }

  write_register_b(c.io.reg_tmodes, 0, Some(h != 0))
  if (THREADS > 1) {
    for (i <- (1 to 3)) {
      write_register_b(c.io.reg_tmodes, i, Some(h != i))
    }
  }

  if (THREADS > 4) {
    for (i <- (4 to 7)) {
      write_register_b(c.io.reg_tmodes, i, Some(h != i))
    }
  }

  if (config.flex) {
    // Active thread in slot 0
    write_register(c.io.reg_slots, 0, h)
    // Use SRTT (14) or disabled (15) slot values to achieve f.
    for (i <- 1 to 7) {
      write_register(c.io.reg_slots, i, if (f > i) 14 else 15)
    }
  }

  // Step to execute all the write_registers
  step(1)
  // Unfreeze the registers
  c.io.reg_tmodes.freeze.foreach { x => poke(x, 0) }
  c.io.reg_tmodes.write.foreach { x => poke(x.valid, 0) }
  c.io.reg_slots.freeze.foreach { x => poke(x, 0) }
  c.io.reg_slots.write.foreach { x => poke(x.valid, 0) }
  c.io.datapath_exe_reg_pc.freeze.foreach { x => poke(x, 0) }
  c.io.datapath_exe_reg_pc.write.foreach { x => poke(x.valid, 0) }

  // I/O pins
  // Scala is sorely missing types like uint8_t, uint32_t, etc...
  var tohost: UInt = 0.U(32.W) // 32.W
  var tohost_prev = 0.U(32.W);
  val gpio = Seq.fill(4)(BigInt(0)).toBuffer
  val gpio_prev = Seq.fill(4)(BigInt(0)).toBuffer
  /*
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
  */
  // Simulate processor until termination signal or max cycles reached
  CoreTesterMain.Globals.done = false
  while (!CoreTesterMain.Globals.done && (max_cycles == 0 || CoreTesterMain.Globals.cycle < max_cycles)) {

    // Setup inputs.

    // Signals from program to trigger emulator behavior.
    // Hack to trigger external interrupt (w/ csrr a0, frm)
    if (peek(c.io.datapath_dec_reg_inst.read(0)) == 0x00202573) {
      poke(c.io.int_exts(0), true)
    } else {
      poke(c.io.int_exts(0), false)
    }
/*

                      // Check outputs.
                      c->clock_lo(LIT<1>(0));

                      // TODO: add stats

                      // Currently assume all peripheral bus writes are characters
                      //if(c->Core__io_bus_enable.to_bool() && c->Core__io_bus_write.to_bool() && ((c->Core__io_bus_addr.lo_word() & ) == 0x...)) {
                      if(c->Core__io_bus_enable.to_bool() && c->Core__io_bus_write.to_bool()) {
                          printf("%c", c->Core__io_bus_data_in.lo_word());
                      }
*/
    // Monitor GPIO
    gpio(0) = peek(c.io.gpio.out(0))
    gpio(1) = peek(c.io.gpio.out(1))
    gpio(2) = peek(c.io.gpio.out(2))
    gpio(3) = peek(c.io.gpio.out(3))
    for (i <- (0 until 4)) {
      if (gpio(i) != gpio_prev(i)) {
        println(s"GPIO (tid = ${i}, cycle = %7d): 0x%08x".format(CoreTesterMain.Globals.cycle, gpio(i)))
      }
      gpio_prev(i) = gpio(i)
    }

    // Monitor to_host
    tohost = peek(c.io.host.to_host).U(32.W)
    if (tohost.litValue != tohost_prev.litValue) {
      if (tohost.litValue == 1) {
        println(s"*** PASSED ${msg}***")
        CoreTesterMain.Globals.done = true
      }
      if (tohost.litValue > 1) {
        println(s"*** FAILED ${msg}***(test #${tohost})")
        CoreTesterMain.Globals.failed = true
        CoreTesterMain.Globals.done = true
      }
    }
    tohost_prev = tohost

    /*
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
*/
    // Text trace
    if (trace) {
      val exe_reg_tid = 0 // c -> Core_datapath__exe_reg_tid.lo_word()
      val exe_valid = 0 // c -> Core_control__exe_valid.lo_word()
      val exe_reg_pc = peek(c.io.datapath_exe_reg_pc.read(0))
      println(s"Trace:\tcycle = ${CoreTesterMain.Globals.cycle}\t, tid=${exe_reg_tid}\t, valid=${exe_valid}\t, pc=%016x".format(exe_reg_pc))
      // spike
      //if(c->Core_control__exe_valid.to_bool()) {
      //    printf("%5d\t: 0x%016x\n",counter.commit_cycles[exe_tid],c->Core_datapath__exe_reg_pc.lo_word());
      //    //printf("0x%016x\n",c->Core_datapath__exe_reg_pc.lo_word());
      //}
    }

    // Next cycle
    step(1)
    CoreTesterMain.Globals.cycle += 1
  }

  // Check for timeout
  if (CoreTesterMain.Globals.cycle >= max_cycles) {
    println("*** FAILED ***(Max cycles timeout)")
    CoreTesterMain.Globals.failed = true
  }
  /*
                // Print out stats
                //for(int i = 0; i < 4; i++) {
                //    printf("Counters for tid = %d\n", i);
                //    printf("Processor cycles = %llu\n", counter.processor_cycles[i]);
                //    printf("Thread cycles = %llu\n", counter.thread_cycles[i]);
                //    printf("Commit cycles = %llu\n", counter.commit_cycles[i]);
                //}
    */

}

object CoreTesterMain {
  // Globals are evil - refactor this
  object Globals {
    var done: Boolean = false
    var failed: Boolean = false
    var cycle: Int = 0
  }

  def main(args: Array[String]): Unit = {
    if (args.isEmpty) {
      System.err.println("CoreTesterMain usage: configuration_string")
      return
    }
    val confString = args(0)
    val config = FlexpretConfiguration.parseString(confString)

    // Use Verilator for C++ simulation.
    val extraArgs = Array("--backend-name", "verilator")


    val max_cycles_default = 0

    val THREADS = config.threads

    /*


      const char *ispm_filename = NULL;
      const char *dspm_filename = NULL;
      bool vcd = false;
      FILE *vcd_file = NULL;
      const char *vcd_filename = "trace.vcd";
      int vcd_start = 0;
      */

    // Parse command line options.
    val sweep: Boolean = args.collectFirst { case s if s == "--sweep" => true } getOrElse (false)
    val trace: Boolean = args.collectFirst { case s if s == "--trace" => true } getOrElse (false) // Text trace.
    val max_cycles: Int = args.collectFirst { case s if s.startsWith("--maxcycles=") => s.replace("--maxcycles=", "").toInt }.getOrElse(max_cycles_default)

    // Remove them from the args passed to Chisel.
    // TODO: make this less redundant
    val cleanedArgs = args.filterNot(s =>
      s == "--sweep" ||
        s == "--trace" ||
        s.startsWith("--maxcycles") ||
        s.startsWith("--ispm") ||
        s.startsWith("--dspm") ||
        s.startsWith("--vcd")
    )

    /*

        int current_option;
        int option_index = 0;
        static struct option long_options[] = {
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
    */
    val f_s = if (config.flex) 1 else THREADS
    val f_e = if (config.flex) {
      if (sweep) 8 else 1
    } else THREADS

    val h_e = if (sweep) THREADS else 1

    if (sweep) {
      println("sweep");
    }

    // Iterate through test configurations
    for (h <- (0 until h_e)) {
      for (f <- (f_s to f_e)) {
        Driver.execute(cleanedArgs ++ extraArgs, () => new Core(config)) {
          c => new CoreTester(c, config, sweep, trace, max_cycles, h, f)
        }
      }
    }
  }
}
