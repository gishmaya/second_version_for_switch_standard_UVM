class package_fc_subscriber extends uvm_subscriber#(package_c);
  `uvm_component_utils(package_fc_subscriber)
 
  package_c pkg_tx;
      
  covergroup package_cg;
    inter_package_gap_cp: coverpoint pkg_tx.inter_package_gap{ 
      bins low = {[1:3]}; 
      bins high = {[10:40]};
    }
    package_length_cp:    coverpoint pkg_tx.head.package_length {
      bins max = {15};
      bins nim = {1}; 
      bins med = {7}; 
      bins short ={[2:6]}; 
      bins long = {[8:14]};
      }                                                                                                 
    source_address_cp:    coverpoint pkg_tx.head.source_address;
    dest_address_cp:      coverpoint pkg_tx.head.dest_address;
    cross inter_package_gap_cp, package_length_cp, source_address_cp, dest_address_cp;
  endgroup: package_cg
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    package_cg = new;
  endfunction: new
 
  function void write(package_c t);
    pkg_tx = t;
    package_cg.sample();
  endfunction: write
              
endclass: package_fc_subscriber
