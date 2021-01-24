`include "env.sv"

class package_test extends uvm_test;
   `uvm_component_utils(package_test)

  env_c pkg_env;
  virtual package_i my_package_temp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pkg_env = env_c::type_id::create("pkg_env", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual package_i)::get(.cntxt(this),.inst_name(""),.field_name("package_i_0"),.value(my_package_temp)))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(),".package_i_0"});
    pkg_env.agent0.monitor_in_i.my_package_i=my_package_temp;
    pkg_env.agent0.monitor_in_i.num_of_this_agent=0;
    pkg_env.agent0.pkg_drvr.my_package_i=my_package_temp;
    pkg_env.agent0.pkg_drvr.num_of_this_agent=0;

    if(!uvm_config_db#(virtual package_i)::get(.cntxt(this),.inst_name(""),.field_name("package_i_1"),.value(my_package_temp)))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(),".package_i_1"});
    pkg_env.agent1.monitor_in_i.my_package_i=my_package_temp;
    pkg_env.agent1.monitor_in_i.num_of_this_agent=1;
    pkg_env.agent1.pkg_drvr.my_package_i=my_package_temp;
    pkg_env.agent1.pkg_drvr.num_of_this_agent=1;

  endfunction: connect_phase
  
  task run_phase(uvm_phase phase);
    sequence_transaction pkg_seq_0;
    sequence_transaction pkg_seq_1;
    reg_sequence         reg_seq;
     
    phase.raise_objection(.obj(this));
     
    reg_seq = reg_sequence::type_id::create(.name("reg_seqr"), .contxt(get_full_name()));
    assert(reg_seq.randomize());
    reg_seq.regs_block = pkg_env.regs_block;
    //`uvm_info("reg_test", { "\n", reg_seq.sprint() }, UVM_LOW)  
    reg_seq.start(null);
    fork
      begin 
        pkg_seq_0 = sequence_transaction::type_id::create(.name("pkg_seqr"), .contxt(get_full_name()));
        assert(pkg_seq_0.randomize());    
        pkg_seq_0.start(pkg_env.agent0.pkg_seqr);
      end
      begin
        pkg_seq_1 = sequence_transaction::type_id::create(.name("pkg_seqr"), .contxt(get_full_name()));
        assert(pkg_seq_1.randomize());    
        pkg_seq_1.start(pkg_env.agent1.pkg_seqr);
      end 
    join_none 
    #30000ns ;
    pkg_env.summary_phase();
    phase.drop_objection(.obj(this));
  endtask: run_phase
  
endclass: package_test
