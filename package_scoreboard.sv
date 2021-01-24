`include "sb_subscriber.sv"

class package_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(package_scoreboard)
  integer pushed_0=0;
  integer pushed_1=0;
  integer accepted=0;
  integer mismatch=0;
  integer match=0;
  SW_reg_block        regs_block;
  
  uvm_analysis_export#(package_c) analysis_export0;
  uvm_analysis_export#(package_c) analysis_export1;
   
  package_sb_subscriber pkg_sb_sub0;
  package_sb_subscriber pkg_sb_sub1;

  package_c expected_packets0[$];
  package_c expected_packets1[$];
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export0 = new( .name("analysis_export0"), .parent(this));
    analysis_export1 = new( .name("analysis_export1"), .parent(this));
    pkg_sb_sub0 = package_sb_subscriber::type_id::create(.name("pkg_sb_sub0"), .parent(this));
    pkg_sb_sub1 = package_sb_subscriber::type_id::create(.name("pkg_sb_sub1"), .parent(this));
    pkg_sb_sub0.num_of_ap=0;
    pkg_sb_sub1.num_of_ap=1;
  endfunction: build_phase
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    analysis_export0.connect(pkg_sb_sub0.analysis_export);
    analysis_export1.connect(pkg_sb_sub1.analysis_export);
  endfunction: connect_phase
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new
 
  function void reference_model(package_c pkg);
    integer dst=get_dest_by_map(pkg.head.dest_address);    
    if(dst==0)
      begin
        expected_packets0.push_back(pkg);
        `uvm_info("packet pushed to expected0!", { "\n" }, UVM_LOW)
        pkg.print_package();
        pushed_0=pushed_0+1;
      end
    if(dst==1)
      begin
        expected_packets1.push_back(pkg);
        `uvm_info("packet pushed to expected1!", { "\n" }, UVM_LOW)
        pkg.print_package();
        pushed_1=pushed_1+1;
      end
  endfunction
  
  function void check_package(package_c pkg, integer num_of_ap);
    package_c expected_packet;
    `uvm_info("check pkg from scoreboard!", { "\n" }, UVM_LOW)
    if(num_of_ap==0)
      expected_packet=expected_packets0.pop_front();
    if(num_of_ap==1)
      expected_packet=expected_packets1.pop_front();
    if(expected_packet.compare(pkg))
      begin
        this.match=this.match+1;
        `uvm_info("      check_phase (scoreboard_c, task) -> match! ", { "\n" }, UVM_LOW)
      end
    else
      begin
        this.mismatch=this.mismatch+1;
        `uvm_error(get_name(), "      check_phase (scoreboard_c, task) -> mismatch! here are the packets: ") 
        pkg.print_package();
        expected_packet.print_package();
      end  
  endfunction
   
  function int get_dest_by_map(integer pkg_dest_address);
    integer map = regs_block.addr_map_reg.get();
    for(int i=0;i<pkg_dest_address+1;i++)
      begin
        if(i==pkg_dest_address)
          map=map%2;
        else
          map=map/2;
      end
    return map;
  endfunction
  
  function void summary_phase();
    $display(""); 
    $display("***********************SCOREBOARD SUMMARY************************");
    $display(""); 

    //$display("Total errors:", error_source_pkt);
    //$display("");
    //$display("        TOTAL");
    
    $display(" Expected packets:", pushed_0 + pushed_1);
    $display(" Actual packets:", accepted);
    $display("");
    $display(" Match:", match);
    $display(" Mismatch:", mismatch);
    $display("");
    $display("*****************************************************************");
    $display("");
  endfunction
  
endclass: package_scoreboard
  
  
  
 







  
  
 //typedef class package_sb_subscriber;
 
  
    
  /*package_c waiting_list0[$];
  package_c waiting_list1[$];
  package_c tmp_list[$];
  package_c tmp_pkg;*/
  
  
  /*  function void check_package(package_c pkg);
    integer dst=get_dest_by_map(pkg.head.dest_address);
    package_c expected_packet;
    `uvm_info("check pkg from scoreboard!", { "\n" }, UVM_LOW)
    //if(regs_block.addr_map_c.data)
      begin
        if(dst==0)
          expected_packet=expected_packets0.pop_front();
        if(dst==1)
          expected_packet=expected_packets1.pop_front();
      end
    if(expected_packet.compare(pkg))
      begin
        this.match=this.match+1;
        `uvm_info("      check_phase (scoreboard_c, task) -> match! ", { "\n" }, UVM_LOW)
      end
    else
      begin
        /*if(dst==0)
          begin
            for(int i=0;i<waiting_list0.size();i++)
              begin
                tmp_pkg = waiting_list0.pop_front();
                if(expected_packet.compare(tmp_pkg))
                  begin
                    this.match=this.match+1;
                    `uvm_info("      check_phase (scoreboard_c, task) -> match! ", { "\n" }, UVM_LOW)
                  end
                else
                  waiting_list0.push_back(tmp_pkg);  
              end
            this.mismatch=this.mismatch+1;
            `uvm_error(get_name(), "      check_phase (scoreboard_c, task) -> mismatch! here are the packets: ") 
            pkg.print_package();
            expected_packet.print_package();
            //waiting_list0.push_front(expected_packet);
          end
        if(dst==1)
          begin
            for(int i=0;i<waiting_list1.size();i++)
              begin
                tmp_pkg = waiting_list1.pop_front();
                if(expected_packet.compare(tmp_pkg))
                  begin
                    this.match=this.match+1;
                    `uvm_info("      check_phase (scoreboard_c, task) -> match! ", { "\n" }, UVM_LOW)
                  end
                else
                  waiting_list1.push_back(tmp_pkg);  
              end
            this.mismatch=this.mismatch+1;
            `uvm_error(get_name(), "      check_phase (scoreboard_c, task) -> mismatch! here are the packets: ") 
            pkg.print_package();
            //expected_packet.print_package();
            //waiting_list1.push_front(expected_packet);
          end        
      end  
  endfunction*/
