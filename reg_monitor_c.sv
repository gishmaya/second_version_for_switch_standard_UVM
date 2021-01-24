class reg_monitor_c extends uvm_monitor;
  `uvm_component_utils(reg_monitor_c)
 
  uvm_analysis_port#(reg_sequence_c) reg_ap;
  virtual conf_DUT_i          conf_if;
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert( uvm_config_db#( virtual interface conf_DUT_i )::
         get( .cntxt( this ), .inst_name( "" ), .field_name( "conf_dut" ), .value( conf_if ) ) );
    reg_ap = new(.name("reg_ap"), .parent(this));
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    reg_sequence_c reg_transaction = new();
    forever
      begin
        @(posedge conf_if.conf_data_valid)
        reg_transaction.address = conf_if.conf_address;
        reg_transaction.data = conf_if.conf_data_write;//if write
        reg_transaction.r_or_w = conf_if.conf_read_write == 1 ? READ : WRITE;
        if(reg_transaction.r_or_w == READ)
          begin
            @(posedge conf_if.clk);
            #1ns;
            reg_transaction.data = conf_if.conf_data_read;
          end
        reg_ap.write(reg_transaction);
      end
    
  endtask
    
endclass
