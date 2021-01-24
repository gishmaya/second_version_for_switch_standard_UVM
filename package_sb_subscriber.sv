typedef class package_scoreboard;
 
class package_sb_subscriber extends uvm_subscriber#(package_c);
  `uvm_component_utils(package_sb_subscriber)
  package_scoreboard pkg_sb;
  integer num_of_ap;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new
 
  function void write(package_c t);
    $cast( pkg_sb, m_parent );
    if(t.packet_in_or_out==0) 
      pkg_sb.reference_model(t);
    if(t.packet_in_or_out==1)
      begin
        pkg_sb.check_package(t,num_of_ap);
        pkg_sb.accepted=pkg_sb.accepted+1;
      end
  endfunction: write
endclass: package_sb_subscriber
