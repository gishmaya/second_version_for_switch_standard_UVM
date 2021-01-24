typedef uvm_sequencer#(package_c) package_sequencer;
    
class package_transaction_c extends uvm_sequence#(package_c);
  `uvm_object_utils(package_transaction_c)
    
  function new(string name = "" );
    super.new(name);
  endfunction
   
  task body();
    package_c pkg_tx;
    int i ;
    for(i = 0 ; i < 20 ; ++i)
      begin
        pkg_tx = package_c::type_id::create(.name("pkg_seq"), .contxt(get_full_name()));
        start_item(pkg_tx);
        assert(pkg_tx.randomize());
        finish_item(pkg_tx);
      end
  endtask: body
    
endclass: package_transaction_c
