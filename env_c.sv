`include "agent.sv"
`include "reg_transaction.sv"
`include "scoreboard.sv"
`include "reg_agent.sv"
`include "fc_subscriber.sv"

class env_c extends uvm_env;
  `uvm_component_utils(env_c)
  agent_c#(1)                  agent0;
  agent_c#(1)                  agent1;
  reg_agent_c                  reg_agent;
  package_fc_subscriber        pkg_fc_sub0;
  package_fc_subscriber        pkg_fc_sub1;
  package_scoreboard           pkg_sb;
    
  SW_reg_block                 regs_block;
  SW_reg_adapter               reg_adapter;
  SW_reg_predictor             reg_predictor;
      
  function new(string name, uvm_component parent);
    super.new(name, parent); 
  endfunction: new
 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
    regs_block     = SW_reg_block::type_id::create( "regs_block" );
    regs_block.build();
    agent0 =       agent_c#(1)::type_id::create("agent0", this);
    agent1 =       agent_c#(1)::type_id::create("agent1", this);

    reg_agent  = reg_agent_c::type_id::create(.name("reg_agent"), .parent(this)); 
     
    reg_adapter    = SW_reg_adapter::type_id::create(.name("reg_adapter"),      .parent(this));
    reg_predictor  = SW_reg_predictor::type_id::create(.name("reg_predictor"),    .parent(this));
     
    pkg_fc_sub0 = package_fc_subscriber::type_id::create(.name("pkg_fc_sub0"), .parent(this));
    pkg_fc_sub1 = package_fc_subscriber::type_id::create(.name("pkg_fc_sub1"), .parent(this));
    pkg_sb     = package_scoreboard::type_id::create(.name("pkg_sb"), .parent(this));
     
  endfunction: build_phase
      
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    pkg_sb.regs_block = regs_block;
    regs_block.reg_map.set_sequencer( .sequencer( reg_agent.reg_seqr ), .adapter( reg_adapter ));
    reg_predictor.map = regs_block.reg_map;
    reg_predictor.adapter = reg_adapter;
    reg_agent.reg_ap.connect( reg_predictor.bus_in );     
    agent0.pkg_ap.connect(pkg_fc_sub0.analysis_export);
    agent0.pkg_ap.connect(pkg_sb.analysis_export0);
    agent1.pkg_ap.connect(pkg_fc_sub1.analysis_export);
    agent1.pkg_ap.connect(pkg_sb.analysis_export1);
  endfunction: connect_phase
         
  function void summary_phase();
    pkg_sb.summary_phase();    
  endfunction
  
endclass
