//------------------------------------------------------------------------------
// File        : apb_env.sv
// Project     : APB UVM Verification Environment
// Description :
//   APB environment that instantiates the verification components and
//   connects the monitor to the scoreboard and subscriber.
//------------------------------------------------------------------------------

class apb_env extends uvm_env;
  
  // Register the environment with the UVM factory
  `uvm_component_utils(apb_env)
  // Environment components
  apb_scoreboard 	sb;
  apb_subscriber 	sc;
  apb_agent 		ag;
  
  // Constructor 
  function new(string name="apb_environment",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create all top-level verification components.
    sb=apb_scoreboard::type_id::create("scoreboard",this);
    sc=apb_subscriber::type_id::create("subscriber",this);
    ag=apb_agent::type_id::create("agent",this);
    
  endfunction
  
  // Connect Phase: Connect the monitor's analysis port to the scoreboard and subscriber.
  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    // Send monitored transactions to the scoreboard
    ag.mon.ap.connect(sb.sb_imp);
    // Send monitored transactions for functional coverage
    ag.mon.ap.connect(sc.analysis_export);
    
  endfunction
  
endclass
    
    
  
  