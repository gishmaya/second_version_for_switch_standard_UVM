typedef enum { READ, WRITE } W_or_R;
class reg_sequence_c extends uvm_sequence_item;

  bit [3:0] address;
  bit [15:0] data;
  W_or_R r_or_w;
  string name;
  
  function new(string name = "");
    super.new(name);
    assert(this.randomize());
  endfunction: new
  
  function void print();
    $display("There is a reg! name: ",this.name,", address: ",this.address, ", data: ", this.data, ", reg is for ", this.r_or_w);
  endfunction: print
  
  `uvm_object_utils_begin(reg_sequence_c)
  `uvm_field_int(address, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_field_string(name, UVM_ALL_ON)
  `uvm_object_utils_end
  
endclass

class addr_map_c extends uvm_reg;
  `uvm_object_utils( addr_map_c )
  
  uvm_reg_field data;

  function new( string name = "addr_map_c" );
    super.new( .name( name ), .n_bits(8), .has_coverage( UVM_NO_COVERAGE ) );
  endfunction: new

  virtual function void build();
    data = uvm_reg_field::type_id::create( "data" );
		data.configure(     .parent                 ( this ),
                            .size                   ( 8),
                            .lsb_pos                ( 0),
		                    .access                 ( "RW" ),
                            .volatile               ( 0 ),
                            .reset                  ( 8'hA0 ),
                            .has_reset              ( 0 ),
                            .is_rand                ( 1 ),
                            .individually_accessible( 1 ) );
  endfunction: build

endclass: addr_map_c

class addr_prio_c extends uvm_reg;
   `uvm_object_utils( addr_prio_c )
 
   rand uvm_reg_field data;
 
   function new( string name = "addr_prio_c" );
     super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   function void build();
     data = uvm_reg_field::type_id::create("data");
     data.configure(  .parent                 ( this ),
                      .size                   ( 2    ),
                      .lsb_pos                ( 0    ),
                      .access                 ( "RW" ),
                      .volatile               ( 1    ),
                      .reset                  ( 0    ),
                      .has_reset              ( 0    ),
                      .is_rand                ( 1    ),
                      .individually_accessible( 1    ) );
   endfunction: build
  
endclass: addr_prio_c

class SW_reg_block extends uvm_reg_block;
   `uvm_object_utils( SW_reg_block )
 
   rand addr_prio_c addr_prio_reg;
   rand addr_map_c  addr_map_reg;
   uvm_reg_map       reg_map;
 
   function new( string name = "SW_reg_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
     addr_map_reg = addr_map_c::type_id::create( "addr_map_reg" );
     addr_map_reg.configure( .blk_parent( this ) );
     addr_map_reg.build();
     addr_prio_reg = addr_prio_c::type_id::create( "addr_prio_reg" );
     addr_prio_reg.configure( .blk_parent( this ) );
     addr_prio_reg.build();
     reg_map = create_map( .name( "reg_map" ), .base_addr( 8'h00 ), .n_bytes( 16 ), .endian( UVM_LITTLE_ENDIAN ) );
     reg_map.add_reg( .rg( addr_map_reg  ), .offset( 8'h00 ), .rights( "RW" ) );
     reg_map.add_reg( .rg( addr_prio_reg ), .offset( 8'h01 ), .rights( "RW" ) );
     lock_model(); // finalize the address mapping
   endfunction: build
 
endclass: SW_reg_block

class SW_reg_adapter extends uvm_reg_adapter;
   `uvm_object_utils( SW_reg_adapter )
 
   function new( string name = "" );
     super.new( name );
     supports_byte_enable = 0;
     provides_responses   = 1;
   endfunction: new
 
   virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
      
     reg_sequence_c reg_transaction = reg_sequence_c::type_id::create("reg_transaction");
     if ( rw.kind == UVM_READ )       
       reg_transaction.r_or_w = READ;
     else 
       if ( rw.kind == UVM_WRITE ) 
         reg_transaction.r_or_w =WRITE;
       else                             
         `uvm_fatal( get_name(), "Choose if read or write." )         
     if( rw.kind == UVM_WRITE )
       begin
         reg_transaction.data = rw.data;
       end
     reg_transaction.address = rw.addr;
     return reg_transaction;
   endfunction: reg2bus
 
   virtual function void bus2reg( uvm_sequence_item bus_item,ref uvm_reg_bus_op rw );
      
     reg_sequence_c reg_transaction;
     if ( ! $cast( reg_transaction, bus_item ) ) 
       begin
         `uvm_fatal( get_name(),
                     "bus_item is not of the jelly_bean_transaction type." )
         `uvm_info(reg_transaction.address, { "\n" }, UVM_LOW)
         return;
       end
     rw.kind = ( reg_transaction.r_or_w == READ ) ? UVM_READ : UVM_WRITE;
     if ( rw.kind == UVM_WRITE )
       rw.data = reg_transaction.data;
     else 
       rw.data = reg_transaction.data;
     rw.addr = reg_transaction.address;
     rw.status = UVM_IS_OK;
   endfunction: bus2reg
 
endclass: SW_reg_adapter

typedef uvm_reg_predictor#( reg_sequence_c ) SW_reg_predictor;
