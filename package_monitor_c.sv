`include "package_transaction_c.sv"

class package_monitor_c extends uvm_monitor;
  `uvm_component_utils(package_monitor_c)
 
  uvm_analysis_port#(package_c) pkg_ap;
 
  virtual package_i           my_package_i;
  package_c                   ready_pkt;
  integer                      num_of_this_agent;
  string str_for_error="";
   
  covergroup cover_bit with function sample(int num);
     bits_of_num_16: coverpoint num{
       wildcard bins bit_10 ={16'b???????????????0};
       wildcard bins bit_11 ={16'b???????????????1};
       wildcard bins bit_20 ={16'b??????????????0?};
       wildcard bins bit_21 ={16'b??????????????1?};
       wildcard bins bit_30 ={16'b?????????????0??};
       wildcard bins bit_31 ={16'b?????????????1??};
       wildcard bins bit_40 ={16'b????????????0???};
       wildcard bins bit_41 ={16'b????????????1???};
       wildcard bins bit_50 ={16'b???????????0????};
       wildcard bins bit_51 ={16'b???????????1????};
       wildcard bins bit_60 ={16'b??????????0?????};
       wildcard bins bit_61 ={16'b??????????1?????};
       wildcard bins bit_70 ={16'b?????????0??????};
       wildcard bins bit_71 ={16'b?????????1??????};
       wildcard bins bit_80 ={16'b????????0???????};
       wildcard bins bit_81 ={16'b????????1???????};
      /* wildcard bins bit_90 ={16'b???????0????????};
       wildcard bins bit_91 ={16'b???????1????????};
       wildcard bins bit_A0 ={16'b??????0?????????};
       wildcard bins bit_A1 ={16'b??????1?????????};
       wildcard bins bit_B0 ={16'b?????0??????????};
       wildcard bins bit_B1 ={16'b?????1??????????};
       wildcard bins bit_C0 ={16'b????0???????????};
       wildcard bins bit_C1 ={16'b????1???????????};
       wildcard bins bit_D0 ={16'b???0????????????};
       wildcard bins bit_D1 ={16'b???1????????????};
       wildcard bins bit_E0 ={16'b??0?????????????};
       wildcard bins bit_E1 ={16'b??1?????????????};
       wildcard bins bit_F0 ={16'b?0??????????????};
       wildcard bins bit_F1 ={16'b?1??????????????};
       wildcard bins bit_G0 ={16'b0???????????????};
       wildcard bins bit_G1 ={16'b1???????????????};*/
     }
      
    endgroup: cover_bit
      
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cover_bit = new();
  endfunction: new
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pkg_ap = new(.name("pkg_ap"), .parent(this));
    ready_pkt = new();
  endfunction: build_phase
      
  task listen_in_pkg();
    integer length;
    bit [7:0] header;
    bit [7:0] source;
    data_list in_pkt_as_queue;
    
    forever
      begin
        //make the queue empty, before the in_monitor will fill it. the queue will be the packet which have listened
        while(in_pkt_as_queue.size()!=0)
          void'(in_pkt_as_queue.pop_back());
        @(posedge my_package_i.package_in_start);
        in_pkt_as_queue[0]=my_package_i.package_in;
        cover_bit.sample(in_pkt_as_queue[0]);
        header=my_package_i.package_in;
        source=header[3:3];
        length=header[7:4];
        @(posedge my_package_i.clk);
        for(int i=1;i<(length+1);i++)
          begin
            @(posedge my_package_i.clk);
            in_pkt_as_queue[i]=my_package_i.package_in;
            cover_bit.sample(in_pkt_as_queue[i]);
          end 
        in_pkt_as_queue=this.predict(in_pkt_as_queue);
        ready_pkt.unpack(in_pkt_as_queue);
        if(length!=0)
          begin
            ready_pkt.packet_in_or_out = 0;
            pkg_ap.write(ready_pkt);
          end
      end
  endtask
    
  function data_list predict(data_list pkt_as_queue);
    return pkt_as_queue;
  endfunction
  
  task listen_out_pkg();
    int i=0;
    integer length;
    bit [7:0] header;
    bit [7:0] source;
    data_list out_pkt_as_queue;
    package_c actual_pkt=new();
    integer valid_0_last_clk=0;
    integer num_valid_0_cycles;
    forever
      begin
        num_valid_0_cycles=0;
        while(out_pkt_as_queue.size()!=0)
          void'(out_pkt_as_queue.pop_back());
        @(posedge my_package_i.package_out_start);
        if(my_package_i.read_data_valid)
          begin
            header=my_package_i.package_out;
            valid_0_last_clk=0;
          end
        out_pkt_as_queue[0]=header;
        source=header[3:3];
        length=header[7:4];
        @(posedge my_package_i.clk)
        for(i=1;i<(length+1+num_valid_0_cycles);i++)//length+1 because length is without the header
          begin
            @(posedge my_package_i.clk);
            if(my_package_i.read_data_valid)
              begin
                out_pkt_as_queue[i-num_valid_0_cycles]=my_package_i.package_out;
                if((my_package_i.package_out_start==0) && (valid_0_last_clk==1))//now there is valid! otherwise the condition was false
                  begin
                    valid_0_last_clk=0;
                    str_for_error = $psprintf("On the interface of agent %0d", num_of_this_agent,
                                              " expecting rise of signal package_out_start withwin 1 cycle but did not receive it");
                    `uvm_error(get_name(),str_for_error)
                  end
                if((my_package_i.package_out_start==1) && (valid_0_last_clk==0))//if the start is 1 despite it have to be 0, valid is 1 like the last comment
                  begin
                    valid_0_last_clk=0;
                    str_for_error = $psprintf("On the interface of agent %0d", num_of_this_agent,
                                              " expecting to see the signal package_out_start asserted withwin 1 cycle but did not see.");
                    `uvm_error(get_name(), str_for_error)
                  end
                valid_0_last_clk=0;//to prevent flag on, for more than 1 cycle*/
              end
            else
              begin
                num_valid_0_cycles++;
                valid_0_last_clk = 1;
              end
          end
        @(posedge my_package_i.clk);
        if((my_package_i.read_data_valid==1) && (my_package_i.package_out_start==0) && 
           ((my_package_i.package_out!=0) || (my_package_i.package_out == out_pkt_as_queue[length+1]) ) && length +1 ==i+num_valid_0_cycles)
              begin
                str_for_error = $psprintf("On the interface of agent %0d", num_of_this_agent," expecting to see the signal package_out asserted withwin 1 cycle but did not see.");
                `uvm_error(get_name(), str_for_error)  
                `uvm_info("it's looks like another packet start but the start is 0! start is 0 valid is 1, package_out is not 0", { "\n" }, UVM_HIGH)
              end
        actual_pkt.unpack(out_pkt_as_queue);
        if(length)
          begin
            actual_pkt.packet_in_or_out = 1;
            pkg_ap.write(actual_pkt);
            `uvm_info("A new pkg come from DUT was written!", { "\n" }, UVM_LOW)
          end
        else
          `uvm_error(get_name(), "out_monitor -> A packet with length 0!")  
    end
  endtask
                 
  task run_phase(uvm_phase phase);
    fork 
      listen_out_pkg();
      listen_in_pkg();
    join_none
  endtask
endclass: package_monitor_c
       
