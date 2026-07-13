//------------------------------------------------------------------------------
// File        : apb_scoreboard.sv
// Project     : APB UVM Verification Environment
// Description :
//   APB scoreboard used to verify DUT functionality by comparing the
//   monitored transactions against a reference memory model.
//
//   - WRITE : Updates the reference memory.
//   - READ  : Compares DUT read data with expected data.
//------------------------------------------------------------------------------

class apb_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(apb_scoreboard)
  // Analysis implementation port to receive transactions from monitor
  uvm_analysis_imp#(apb_transaction,apb_scoreboard) sb_imp;
  // Queue used to store monitored transactions
  apb_transaction exp_d[$];
  // Reference memory model used for data comparison
  bit [31:0] mem [0:255];
  
  function new(string name="apb_scoreboard",uvm_component parent);
    super.new(name,parent);
    sb_imp=new("Scoreboard",this);		// Create analysis implementation port
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach(mem[i]) mem[i]=i;		// Initialize reference memory with known values
  endfunction
  
  // Callback function invoked automatically whenever the monitor
  // broadcasts a transaction through its analysis port.
  function void write(apb_transaction tr);
    exp_d.push_back(tr);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
    
    
     forever begin
        apb_transaction ep;
        // Wait until at least one monitored transaction is available
        wait(exp_d.size()>0);
        // Retrieve the oldest transaction from the queue
        ep=exp_d.pop_front();
		//------------------------------------------------------------
        // WRITE Operation
        // Update the reference memory with the write transaction.
        //------------------------------------------------------------
        if(ep.pwrite==apb_transaction::WRITE)begin
          mem[ep.addr]=ep.data;
          `uvm_info("APB_SCOREBOARD",$sformatf("------ :: WRITE DATA Match :: ------"),UVM_LOW)
          `uvm_info("",$sformatf("Addr: %0h",ep.addr),UVM_LOW)
          `uvm_info("",$sformatf("Data: %0h",ep.data),UVM_LOW)  
        end
        //------------------------------------------------------------
        // READ Operation
        // Compare DUT read data against the reference memory.
        //------------------------------------------------------------
        else if(ep.pwrite==apb_transaction::READ) begin
          // Compare expected data with actual DUT data
          if(mem[ep.addr]==ep.data) begin
            `uvm_info("APB_SCOREBOARD",$sformatf("------ :: READ DATA Match :: ------"),UVM_LOW)
            `uvm_info("",$sformatf("Addr: %0h",ep.addr),UVM_LOW)
            `uvm_info("",$sformatf("Expected Data: %0h Actual Data: %0h",mem[ep.addr],ep.data),UVM_LOW)
          end
         else begin
           `uvm_error("APB_SCOREBOARD",$sformatf("------ :: READ DATA MISMATCH :: ------"))
           `uvm_info("",$sformatf("Addr: %0h",ep.addr),UVM_LOW)
           `uvm_info("",$sformatf("Expected Data: %0h Actual Data: %0h",mem[ep.addr],ep.data),UVM_LOW)
         end
        end
       end
  endtask
endclass
    