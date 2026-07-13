//------------------------------------------------------------------------------
// File        : apb_subscriber.sv
// Project     : APB UVM Verification Environment
// Description :
//   APB subscriber used to collect functional coverage.
//   Every transaction received from the monitor is sampled into
//   the defined covergroup.
//------------------------------------------------------------------------------

class apb_subscriber extends uvm_subscriber#(apb_transaction);
  
  // Register subscriber with the UVM factory
  `uvm_component_utils(apb_subscriber)
 
  // Variables sampled by the covergroup
  bit [31:0] addr;
  bit [31:0] data;
  
  // Covergroup: Collects functional coverage for APB address and data values.
  covergroup group;
    // Address coverage
    coverpoint addr{
      bins a[16]={[0:255]};
    }
    
    // Data coverage
    coverpoint data{
      bins d[16]={[0:255]};
    }
  endgroup
  
  // Constructor
  function new(string name="apb_subscriber",uvm_component parent);
    super.new(name,parent);
    // Create covergroup instance
    group=new;
  endfunction
  
  //Function : write
  // Called automatically whenever the monitor broadcasts a transaction through its analysis port.
  virtual function void write(apb_transaction t);
    `uvm_info("APB_SUBSCRIBER",$sformatf("Coverage Sampled:%s",t.convert2string()),UVM_NONE)
    
    // Copy transaction fields into covergroup variables
    addr=t.addr;
    data=t.data;
    // Sample functional coverage
    group.sample();
    
  endfunction
  
endclass
    
