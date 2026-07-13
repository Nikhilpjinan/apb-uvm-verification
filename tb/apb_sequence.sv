//------------------------------------------------------------------------------
// File        : apb_sequence.sv
// Project     : APB UVM Verification Environment
// Description :
//   Generates randomized APB read and write transactions and sends them
//   to the sequencer for execution by the driver.
//------------------------------------------------------------------------------


class apb_sequence extends uvm_sequence#(apb_transaction);
  
  //register the class with uvm factory
  `uvm_object_utils(apb_sequence)
  
   // Constructor
  function new(string name="apb_sequence");
    super.new(name);
  endfunction
 
  //task for defining the sequence body
  task body();
    
    apb_transaction tr;
    
    // Generate 100 randomized APB transactions
    repeat(100) begin
      
      // Create a new transaction
      tr=apb_transaction::type_id::create("tr");
      // Request control of the sequencer
      start_item(tr);
      // Randomize transaction fields
      assert(tr.randomize());
      // Send transaction to the driver
      finish_item(tr);
      
       // Display generated transaction
      `uvm_info(get_type_name(),$sformatf("Transaction Generated:%s",tr.convert2string()),UVM_LOW)
      
    end
    
  endtask
  
endclass
                
                