typedef uvm_sequencer#(package_c) package_sequencer;
    
class sequence_transaction extends uvm_sequence#(package_c);
  `uvm_object_utils(sequence_transaction)
    
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
    /*for(i = 0 ; i < 20 ; ++i)
      begin
        pkg_tx = package_c::type_id::create(.name("pkg_seq"), .contxt(get_full_name()));
        start_item(pkg_tx);
        assert(pkg_tx.randomize() with { pkg_tx.head.dest_address <= 7; } );//with {pkg_tx.dest_address ==2;});
        finish_item(pkg_tx);
      end*/
  endtask: body
    
endclass: sequence_transaction
