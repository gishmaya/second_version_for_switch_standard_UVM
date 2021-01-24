
class package_driver_c#(parameter MASTER = 3) extends uvm_driver#(package_c);
  `uvm_component_param_utils(package_driver_c#(MASTER))
  virtual package_i my_package_i;
  parameter L_MASTER = MASTER;
  integer num_of_this_agent;
  string str_for_error="";
  
  function new(string name , uvm_component parent );
    super.new(name, parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(L_MASTER == 3)
      `uvm_fatal("NOT_PARAMETER_TYPE", "You didn't assign the driver - parametric type");
    if(L_MASTER == 1)
      begin
      end
  endfunction: build_phase
    
  task run_phase(uvm_phase phase);
    package_c pkg_tx;
    forever 
      begin
        @(posedge my_package_i.clk)
        seq_item_port.get_next_item(pkg_tx);
        send_packege(pkg_tx.get_data());
        wait_ipg(pkg_tx.inter_package_gap);
        seq_item_port.item_done();
      end
  endtask: run_phase

  //This function counts a clock rise between sending each package.
  task wait_ipg(integer ipg);
    int i = 1;
    while(i < ipg)
      begin
        @(posedge my_package_i.clk);
        ++i;
      end
  endtask
           
  task send_packege(data_list d_list);
    @(posedge my_package_i.clk);
    my_package_i.package_in_start <= 1;
    my_package_i.package_in <= d_list[0];
    @(posedge my_package_i.clk);
    my_package_i.package_in_start <= 0;
    for(int i = 1 ; i < d_list.size() ;++i)
      begin
        my_package_i.package_in <= d_list[i];
        @(posedge my_package_i.clk);
        if(!my_package_i.package_ack && i==1)
          begin
            str_for_error = $psprintf("On the interface of agent %0d", num_of_this_agent, " expecting rise of signal package_ack withwin 1 cycle but did not receive it");
            `uvm_error(get_name(),str_for_error)
            break;
          end
      end
    my_package_i.package_in <= 0;
  endtask
           
endclass:package_driver_c


//with {package_length >= min && package_length <= max ;};
