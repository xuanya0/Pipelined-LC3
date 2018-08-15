import lc3b_types::*;

module mem_wb_reg
(
    input clk,
    input load,
	 input clear,
	 input ctrl_struct ctrl_in,
    input [16-1:0] pc_in, ir_in, mem_in, alu_in,
	 output logic [16-1:0] pc_out, ir_out, mem_out, alu_out,
	 output ctrl_struct ctrl_out
	 
	 
);

register #(.width(16)) ir (.*, .in(ir_in), .out(ir_out));
register #(.width(16)) pc (.*, .in(pc_in), .out(pc_out));
register #(.width(30)) ctrl (.*, .in(ctrl_in), .out(ctrl_out));
register #(.width(16)) mem_reg (.*, .in(mem_in), .out(mem_out));
register #(.width(16)) alu_reg (.*, .in(alu_in), .out(alu_out));


lc3b_opcode operation;
assign operation = lc3b_opcode'(ir_out[15:12]);


endmodule : mem_wb_reg
