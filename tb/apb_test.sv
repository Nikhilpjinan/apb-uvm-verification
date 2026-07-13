//------------------------------------------------------------------------------
// File        : apb_test.sv
// Project     : APB UVM Verification Environment
// Description :
//   Top-level UVM test that builds the verification environment,
//   starts the APB sequence, and controls the simulation using
//   UVM objections.
//------------------------------------------------------------------------------

class apb_test extends uvm_test;
  
  // Register the test with the UVM factory
  `uvm_component_utils(apb_test)
  // APB verification environment
  apb_env env;
  
  // Constructor
  function new(string name="apb_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // Build Phase: Create the APB verification environment.
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=apb_env::type_id::create("environment",this);
  endfunction
  
  // Run Phase: Creates and starts the APB sequence.
  task run_phase(uvm_phase phase);
    
    apb_sequence seq;
    
    super.run_phase(phase);
    // Prevent the simulation from ending while the sequence is running
    phase.raise_objection(this,"Starting APB sequence");
    
    // Create and start the APB sequence
    seq=apb_sequence::type_id::create("sequence");
    seq.start(env.ag.seqr);
    
    // Allow monitor and scoreboard to complete pending transactions
    phase.phase_done.set_drain_time(this, 100ns);
    
    // End the test
    phase.drop_objection(this,"APB sequence completed");
    
  endtask
  
endclass
    