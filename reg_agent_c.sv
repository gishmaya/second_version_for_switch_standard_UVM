`include "reg_seq.sv"
`include "reg_driver.sv"
`include "reg_monitor.sv"
class reg_agent_c extends uvm_agent;
  `uvm_component_utils(reg_agent_c)
 
  uvm_analysis_port#(reg_transaction_c) reg_ap;
  reg_sequencer reg_seqr;
  reg_driver_c reg_drv;
  reg_monitor_c reg_moni;
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_ap = new(.name("reg_ap"), .parent(this));
    reg_seqr = reg_sequencer::type_id::create(.name("reg_seqr"), .parent(this));
    reg_drv = reg_driver_c::type_id::create(.name("reg_drv"), .parent(this));
    reg_moni = reg_monitor_c::type_id::create(.name("reg_moni"), .parent(this));
  endfunction: build_phase
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reg_drv.seq_item_port.connect(reg_seqr.seq_item_export);
    reg_moni.reg_ap.connect(reg_ap);
  endfunction: connect_phase
  
endclass: reg_agent_c
    
    
