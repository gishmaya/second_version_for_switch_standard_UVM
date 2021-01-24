
import uvm_pkg::*;
`include "test.sv"
module switch_tb();

  reg clk, rst;
  package_i package_i_0(.clk(clk), .rst(rst));
  package_i package_i_1(.clk(clk), .rst(rst));
  conf_DUT_i conf_dut(.clk(clk), .rst(rst));
  
  switch_package SWITCH_PACKAGE(.rst(rst),
                                .clk(clk),
                                .package_in_0(package_i_0.package_in),                                                                                                         .package_in_1(package_i_1.package_in),
                                .package_in_start_0(package_i_0.package_in_start),                                                                                             .package_in_start_1(package_i_1.package_in_start),  
                                .package_ack_0(package_i_0.package_ack), 
                                .package_ack_1(package_i_1.package_ack), 
                                .package_out_0(package_i_0.package_out), 
                                .package_out_1(package_i_1.package_out), 
                                .read_data_valid_0(package_i_0.read_data_valid), 
                                .read_data_valid_1(package_i_1.read_data_valid), 
                                .package_out_start_0(package_i_0.package_out_start), 
                                .package_out_start_1(package_i_1.package_out_start), 
                                .conf_address(conf_dut.conf_address), 
                                .conf_data_write(conf_dut.conf_data_write), 
                                .conf_data_read(conf_dut.conf_data_read),
                                .conf_data_valid(conf_dut.conf_data_valid), 
                                .conf_read_write(conf_dut.conf_read_write)
                               );
  
  initial 
    begin
      run; 
      clk = 0;
      forever #10 clk = ~clk;
    end
  
  initial 
    begin
      uvm_config_db#(virtual package_i)::set(.cntxt(null), .inst_name("*"), .field_name("package_i_0"), .value(package_i_0));
      uvm_config_db#(virtual package_i)::set(.cntxt(null), .inst_name("*"), .field_name("package_i_1"), .value(package_i_1));
      uvm_config_db#(virtual conf_DUT_i)::set(.cntxt(null), .inst_name("*"), .field_name("conf_dut"), .value(conf_dut));
      run_test("package_test"); 
    end
  
  initial 
    begin
      rst = 1;
      #1 rst = 0;
      #21 rst = 1;
    end

  task run;
    $dumpfile("dump.vcd");
    $dumpvars;
  endtask
 
endmodule
