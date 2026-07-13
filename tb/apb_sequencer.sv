//------------------------------------------------------------------------------
// File        : apb_sequencer.sv
// Project     : APB UVM Verification Environment
// Description :
//  APB sequencer responsible for arbitrating and forwarding transaction
//   requests from the sequence to the driver.
//------------------------------------------------------------------------------


class apb_sequencer extends uvm_sequencer#(apb_transaction);
  
  // Register the sequencer with the UVM factory
  `uvm_component_utils(apb_sequencer)
  
  // Constructor
  function new(string name="apb_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass