typedef uvm_sequencer#(reg_transaction_c) reg_sequencer;

class reg_sequence extends uvm_sequence#();
  `uvm_object_utils(reg_sequence)
  
  SW_reg_block regs_block;
  uvm_status_e status = UVM_IS_OK;
  
  function new(string name = "");
    super.new(name);
    assert(this.randomize());
  endfunction: new
 
  task body();
    regs_block.addr_prio_reg.data.set(2'b10);
    regs_block.addr_prio_reg.write(status,regs_block.addr_prio_reg.get());
    regs_block.addr_prio_reg.mirror(status,UVM_CHECK);
    regs_block.addr_map_reg.data.set(8'h88);
    regs_block.addr_map_reg.write(status, regs_block.addr_map_reg.get());
    regs_block.addr_map_reg.mirror(status,UVM_CHECK);
    regs_block.addr_map_reg.data.set(8'hA0);
    regs_block.addr_map_reg.write(status, regs_block.addr_map_reg.get());
    regs_block.addr_map_reg.mirror(status,UVM_CHECK);
    regs_block.addr_map_reg.read(status);
  endtask: body
endclass: reg_sequence
