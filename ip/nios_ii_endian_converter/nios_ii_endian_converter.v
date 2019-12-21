/*
  Legal Notice: (C)2009 Altera Corporation. All rights reserved.  Your
  use of Altera Corporation's design tools, logic functions and other
  software and tools, and its AMPP partner logic functions, and any
  output files any of the foregoing (including device programming or
  simulation files), and any associated documentation or information are
  expressly subject to the terms and conditions of the Altera Program
  License Subscription Agreement or other applicable license agreement,
  including, without limitation, that your use is for the sole purpose
  of programming logic devices manufactured by Altera and sold by Altera
  or its authorized distributors.  Please refer to the applicable
  agreement for further details.
*/

module nios_ii_endian_converter(
  ncs_dataa,
  ncs_n,
  ncs_result
);

  input [31:0] ncs_dataa;
  input ncs_n;
  
  output [31:0] ncs_result;
  wire [31:0] ncs_result;
  
  assign ncs_result = (ncs_n == 0)? {ncs_dataa[7:0], ncs_dataa[15:8], ncs_dataa[23:16], ncs_dataa[31:24]} :
                                    {16'b0, ncs_dataa[7:0], ncs_dataa[15:8]};

endmodule
