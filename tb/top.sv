import uvm_pkg::*;
`include "uvm_macros.svh"
`include "dut_if.sv"
`include "apb_transaction.sv"
`include "apb_sequence.sv"
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_scoreboard.sv"
`include "apb_subscriber.sv"
`include "apb_env.sv"
`include "apb_test.sv"
`include "../rtl/apb_slave.sv"

//------------------------------------------------------------------------------
// File        : top.sv
// Project     : APB UVM Verification Environment
// Author      : Nikhil P Jinan
// Description :
//   Top-level testbench module that instantiates the APB interface,
//   DUT, clock/reset generation, UVM configuration, and waveform dumping.
//------------------------------------------------------------------------------

module top;
  
  // Instantiate APB interface
  dut_if duif();
  
  // Instantiate DUT
  apb_slave dut (.dif(duif));
  
  // Generate APB clock (10 ns period)
  always begin
    #5 duif.pclk=~duif.pclk;
  end
  
  //initialize the clock and reset signals
  initial begin
    duif.pclk=0;
    duif.rst_n=0;
    // Apply active-low reset for five clock cycles
    repeat(5)
      @(posedge duif.pclk);
    duif.rst_n=1;
  end
  
  // Make the virtual interface available to all UVM components
  initial begin
    uvm_config_db#(virtual dut_if)::set(null,"*","vif",duif);
    run_test("apb_test");
  end
  
  // Generate waveform dump for debugging
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
  