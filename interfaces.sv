typedef bit [7:0] data_list [$];

//////////////interface for configuration///////////////
interface conf_DUT_i(input wire clk , rst);
  logic [15:0] conf_data_write;
  logic [15:0] conf_data_read;
  logic [3:0]  conf_address;
  logic        conf_read_write;
  logic        conf_data_valid;
endinterface

//////////////interface for packets///////////////
interface package_i(input wire clk , rst);
  logic  [7:0]   package_in;
  logic  [7:0]   package_out;
  logic          package_in_start;
  logic          package_ack;
  logic          read_data_valid;
  logic          package_out_start;
endinterface
