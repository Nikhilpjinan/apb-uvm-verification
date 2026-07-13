//------------------------------------------------------------------------------
// Class: apb_transaction
// Description:
//   APB transaction object exchanged between the sequence, driver,
//   monitor, and scoreboard.
//
// Fields:
//   addr   - APB address
//   data   - Write data or read response data
//   pwrite - Transaction type (READ / WRITE)
//------------------------------------------------------------------------------

class apb_transaction extends uvm_sequence_item;
  
  rand bit [31:0] addr;				// APB address (0 - 255)
  rand bit [31:0] data;				// Write data / Read data
  // Transaction type
  typedef enum{READ,WRITE} wr;
  rand wr pwrite;
  
  // Register transaction fields with the UVM factory
  `uvm_object_utils_begin(apb_transaction)
  	`uvm_field_int(data,UVM_ALL_ON)
  	`uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_enum(wr,pwrite,UVM_ALL_ON)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name="transaction");
    super.new(name);
  endfunction
  
  // constraints
  constraint limit1{addr inside{[0:255]};}			// Address must be within DUT memory range
  constraint limit2{data inside{[0:255]};}			// Data range used for randomized testing
  
  // Returns transaction information in readable format
  function string convert2string();
    return $sformatf("pwrite=%s, addr=%0d,data=%0d",pwrite.name(),addr,data);
  endfunction
  
endclass
    