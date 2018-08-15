import lc3b_types::*;

module id_ex_reg
(
    input clk,
    input load,
	 input clear,
	 input ctrl_struct ctrl_in,
    input [16-1:0] pc_in, ir_in, reg_a_in, reg_b_in,
    output logic [16-1:0] pc_out, ir_out, reg_a_out, reg_b_out,
	 output ctrl_struct ctrl_out
	 
);

register #(.width(16)) ir (.*, .in(ir_in), .out(ir_out));
register #(.width(16)) pc (.*, .in(pc_in), .out(pc_out));
register #(.width(16)) reg_a (.*, .in(reg_a_in), .out(reg_a_out));
register #(.width(16)) reg_b (.*, .in(reg_b_in), .out(reg_b_out));
register #(.width(30)) ctrl (.*, .in(ctrl_in), .out(ctrl_out));

lc3b_opcode operation;
assign operation = lc3b_opcode'(ir_out[15:12]);

endmodule : id_ex_reg
