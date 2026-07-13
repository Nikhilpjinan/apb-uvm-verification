//------------------------------------------------------------------------------
// File        : apb_driver.sv
// Project     : APB UVM Verification Environment
// Description :
//   APB driver responsible for converting sequence transactions into
//   pin-level APB bus activity. Implements APB SETUP and ACCESS phases
//   for both read and write transactions.
//------------------------------------------------------------------------------

class apb_driver extends uvm_driver#(apb_transaction);
  
  //register the class with uvm factory
  `uvm_component_utils(apb_driver)
  
  // Virtual interface handle used to drive APB signals
  virtual dut_if vif;
  
  function new(string name="apb_driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //build phase : set up the virtual interface connection
  function void build_phase(uvm_phase phase);
    //call the base class build phase
    super.build_phase(phase);
    // Retrieve virtual interface from the configuration database
    if(!uvm_config_db#(virtual dut_if)::get(this,"","vif",vif))begin
      `uvm_fatal("NO VIF","NO VIRTUAL INTERFACE IN DRIVER")
    end
  endfunction
  
  //run_phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
	// Initialize APB control signals
    vif.master_cb.psel	 <=	0;
    vif.master_cb.penable<=	0;
    
    forever begin
      //handle for base sequence
      apb_transaction tr;
      tr=apb_transaction::type_id::create("tr");
      @(vif.master_cb);
      // Receive the next transaction from the sequencer
      seq_item_port.get_next_item(tr);
      @(vif.master_cb);
      // Execute APB read or write transaction
      case(tr.pwrite)
        apb_transaction::READ:drive_read(tr.addr,tr.data);
        apb_transaction::WRITE:drive_write(tr.addr,tr.data);
      endcase
 
      seq_item_port.item_done();
      tr.print();
      
    end
  endtask
  virtual protected task drive_read(input bit [31:0] addr,output logic [31:0]data);
      vif.master_cb.paddr<=addr;
      //-----------------------------
	  // APB SETUP Phase
	  // PSEL    = 1
 	  // PENABLE = 0
	  //-----------------------------
      vif.master_cb.psel	<=	1;
      vif.master_cb.pwrite	<=	0;
      vif.master_cb.penable	<=	0;
      @(vif.master_cb);
      //-----------------------------
      // APB ACCESS Phase
      // PSEL remains asserted
      // PENABLE is asserted
      // Wait until slave asserts PREADY
      //-----------------------------
      vif.master_cb.penable	<=	1;
      // Wait until the slave indicates that the transfer is complete
      do begin  
        @(vif.master_cb);
      end while(vif.master_cb.pready==0); 
      data	=	vif.master_cb.prdata;
      vif.master_cb.psel	<=	0;
      vif.master_cb.penable	<=	0;
  endtask
  
  virtual protected task drive_write(input bit[31:0] addr,input bit[31:0] data);

      vif.master_cb.paddr	<=	addr;
      vif.master_cb.psel	<=	1;
      vif.master_cb.pwrite	<=	1;
      vif.master_cb.pwdata	<=	data;
      vif.master_cb.penable	<=	0;
      @(vif.master_cb);
      vif.master_cb.penable	<=	1;
      do begin  
    	@(vif.master_cb);
      end while(vif.master_cb.pready==0);
      vif.master_cb.psel	<=	0;
      vif.master_cb.penable	<=	0;
    endtask
  
endclass