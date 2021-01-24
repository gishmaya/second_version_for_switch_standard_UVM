class reg_driver_c extends uvm_driver#(reg_transaction_c);
  `uvm_component_utils(reg_driver_c)
  virtual conf_DUT_i conf_if;
 
  function new(string name , uvm_component parent );
    super.new(name, parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert( uvm_config_db#( virtual conf_DUT_i )::
            get( .cntxt( this ), .inst_name( "" ), .field_name( "conf_dut" ), .value( conf_if ) ) );
  endfunction: build_phase
    
  task run_phase(uvm_phase phase);
    reg_transaction_c reg_transaction;
    forever 
      begin
        seq_item_port.get_next_item(reg_transaction);
        send_packege(reg_transaction);
        seq_item_port.item_done(reg_transaction);
      end
  endtask: run_phase
    
  task send_packege(reg_transaction_c reg_t);
    @(posedge conf_if.clk);
    conf_if.conf_data_valid <= 1;
    conf_if.conf_address <= reg_t.address;
    if(reg_t.r_or_w == WRITE)
      begin
        conf_if.conf_read_write <= 0;
        conf_if.conf_data_write <= reg_t.data;
      end
    if(reg_t.r_or_w == READ)
      begin
        conf_if.conf_read_write <= 1;
        @(posedge conf_if.clk);
        #1ns;
        reg_t.data = conf_if.conf_data_read;
      end
    @(posedge conf_if.clk);
    conf_if.conf_data_valid <=0;
  endtask
  
endclass:reg_driver_c
