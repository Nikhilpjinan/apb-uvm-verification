//------------------------------------------------------------------------------
// File        : apb_monitor.sv
// Project     : APB UVM Verification Environment
// Description :
//   Passive UVM monitor that observes APB bus activity and converts
//   signal-level transactions into APB transaction objects. The monitored
//   transactions are broadcast through an analysis port to the scoreboard
//   and subscriber.
//------------------------------------------------------------------------------

class apb_monitor extends uvm_monitor;
  
  // Virtual interface used to sample APB interface signals
  virtual dut_if vif;
  
  //register the class with uvm factory
  `uvm_component_utils(apb_monitor)
  
  // Analysis port used to broadcast monitored transactions
  uvm_analysis_port#(apb_transaction) ap;
  
  //constructor
  function new(string name="apb_monitor", uvm_component parent);
    super.new(name,parent);
    ap=new("analysis_port",this);		// Create analysis port
  endfunction
  
  //build phase : set up the virtual interface connection
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Retrieve virtual interface from the configuration database
    if(!uvm_config_db#(virtual dut_if)::get(this,"","vif",vif))begin
      `uvm_fatal("NO VIF","NO VIRTUAL INTERFACE IN MONITOR")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    // Continuously monitor APB transactions
    forever begin
      apb_transaction tr;
      //------------------------------------------------------------
	  // Wait for the APB SETUP phase
      // Condition:
      //   PSEL    = 1
      //   PENABLE = 0
      //------------------------------------------------------------
      do 
        @(vif.monitor_cb);
      while(vif.monitor_cb.psel!==1 || vif.monitor_cb.penable!==0);
      tr=apb_transaction::type_id::create("transaction");		// Create a transaction object to store sampled bus activity
      tr.addr=vif.monitor_cb.paddr;		// Sample address and transaction type during SETUP phase
      tr.pwrite=(vif.monitor_cb.pwrite)?apb_transaction::WRITE:apb_transaction::READ;
      @(vif.monitor_cb);
      // Verify that the SETUP phase is followed by the ACCESS phase
      
      if(vif.monitor_cb.penable!==1) begin
        `uvm_error("APB", "APB protocol violation: SETUP cycle not followed by ENABLE cycle")
      end
      // Wait until the slave completes the transfer
      do
        @(vif.monitor_cb);
      while(vif.monitor_cb.pready==0);
      // Sample write data or read response
      
      if(vif.monitor_cb.pwrite)
        tr.data=vif.monitor_cb.pwdata;
      else
        tr.data=vif.monitor_cb.prdata;
      
      `uvm_info(get_type_name(),$sformatf("Monitored Values:%s",tr.convert2string()),UVM_LOW)
      ap.write(tr);		// Send monitored transaction to all connected analysis components
 
    end
  endtask
endclass
    
    
    
    