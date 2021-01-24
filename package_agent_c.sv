`include "packet.sv"
`include "package_driver_c.sv"
`include "package_monitor_c.sv"

class package_agent_c#(parameter MASTER =3)  extends uvm_agent;
  `uvm_component_param_utils(package_agent_c#(MASTER))
  uvm_analysis_port#(package_c) pkg_ap;
  
  virtual interface package_i  my_package_i;
  package_sequencer            pkg_seqr;
  package_driver_c#(1)         pkg_drvr;
  package_monitor_c            monitor_in_i;
  parameter                    L_MASTER = MASTER;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
    pkg_ap = new(.name("ap"), .parent(this));
  endfunction: new
      
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pkg_ap = new(.name("pkg_ap"), .parent(this));
    pkg_seqr = package_sequencer::type_id::create(.name("pkg_seqr"), .parent(this));
    pkg_drvr = package_driver_c#(1)::type_id::create(.name("pkg_drvr"), .parent(this));
    monitor_in_i = package_monitor_c::type_id::create(.name("pkg_monitor"), .parent(this));
  endfunction
    
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    pkg_drvr.my_package_i = my_package_i;
    pkg_drvr.seq_item_port.connect(pkg_seqr.seq_item_export);
    monitor_in_i.pkg_ap.connect(pkg_ap);
  endfunction: connect_phase
endclass

