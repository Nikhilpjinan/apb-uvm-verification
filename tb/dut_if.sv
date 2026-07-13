//------------------------------------------------------------------------------
// File        : dut_if.sv
// Project     : APB UVM Verification Environment
// Description :
//   APB interface containing bus signals, clocking blocks, and modports.

interface dut_if;

  logic pclk;
  logic rst_n;
  logic [31:0] paddr;
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] pwdata;
  logic pready;
  logic [31:0] prdata;
  
  //Master Clocking block - used for Drivers
  clocking master_cb @(posedge pclk);
    output paddr, psel, penable, pwrite, pwdata;
    input  prdata,pready;
  endclocking: master_cb

  //Slave Clocking Block - used for any Slave BFMs
  clocking slave_cb @(posedge pclk);
     input  paddr, psel, penable, pwrite, pwdata;
     output prdata;
  endclocking: slave_cb

  //Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge pclk);
     input paddr, psel, penable, pwrite, prdata, pwdata,pready;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);

endinterface