`include "interfaces.sv"

//Head class - that defines all fields that should be the head
///////////////class package_head_c///////////////

class package_head_c extends uvm_sequence_item;
  rand  bit[3:0]   package_length;
        bit        source_address;
  rand  bit[2:0]   dest_address;
  
  constraint package_length_m{
    package_length > 0;
  }
  
  function new(string name = "package_head_c",bit port = 0);
    this.source_address = port;
  	assert(this.randomize());
  endfunction
  
  function bit[7:0] get_head();
    return  {package_length , source_address ,dest_address} ;
  endfunction
  
  function int compare(package_head_c other);
    if((this.package_length  != other.package_length) ||
       (source_address != other.source_address) ||
       (dest_address   != other.dest_address))
      return 0;
    return 1;
  endfunction
  
  `uvm_object_utils_begin(package_head_c)
  `uvm_field_int(package_length, UVM_ALL_ON)
  `uvm_field_int(source_address, UVM_ALL_ON)
  `uvm_field_int(dest_address, UVM_ALL_ON)
  `uvm_object_utils_end
 
endclass
  
///Pact class - Defines all Pact fields, including a head field.
///////////////class package_c///////////////
class package_c extends uvm_sequence_item;
        package_head_c  head;
  rand  bit[7:0]       payload[$];
  rand  bit[7:0]       inter_package_gap;
        bit            packet_in_or_out;
  
  function new(string name = "package_c", integer source_address = 0,min = 0 , max = 16);
    integer i;
    head = new(source_address);
    i = head.randomize() with {
      package_length >= min && package_length <= max ;
    };
    
  	assert(this.randomize());
  endfunction
    
   constraint payload_length_m{
     payload.size() == head.package_length;
  }
  
  constraint inter_package_gap_m{
    inter_package_gap > 30 && inter_package_gap <= 35;
  }
 
  function int payload_len_eq_pkg_len();
    return payload.size() == head.package_length ;
  endfunction
    
  function data_list get_data();  
    get_data.push_back(head.get_head());
    for( int i=0 ; i<payload.size; i++)begin
      get_data.push_back(payload[i]);
    end
  endfunction
  
  function void unpack(data_list d_list);
    int i ;
    if(d_list.size > 1) begin
      bit[7:0] header = d_list[0];
      this.head.package_length = header[7:4];
      this.head.source_address = header[3];
      this.head.dest_address = header[2:0];
      
      while(payload.size() > 0)
        void'(payload.pop_back());
      
      for( i = 0 ; i <= header[7:4]  ; ++i ) begin
        this.payload[i] = d_list[i+1];
      end
    end
  endfunction
  
  function int compare(package_c other);
    int i ;
    if(this==null ||other== null)
      return 0;
    if((!this.head.compare( other.head)) ||
       (payload.size() != other.payload.size()))
      return 0;
    
    for(i = 0 ; i < payload.size(); ++i )
      if(payload[i] != other.payload[i])
        return 0;
   return 1;
  endfunction
  
  
  function void print_package();
    if(this)
      begin
        $display("      print (packet_c, function) ->  packet length is: ",
             this.head.package_length," packet came from port ",this.head.source_address,
             " packet have to go to ",this.head.dest_address," the data is: ");
        $write("         ");
        for(int i=0;i<head.package_length;i++)
          $write("%h",this.payload[i], "  ");
        $display("");
      end
  endfunction
  
  `uvm_object_utils_begin(package_c)
  `uvm_field_object( head, UVM_ALL_ON)
  `uvm_field_queue_int(payload, UVM_ALL_ON)
  `uvm_field_int(inter_package_gap, UVM_ALL_ON)
  `uvm_object_utils_end 
  
endclass

