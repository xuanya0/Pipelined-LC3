import lc3b_types::*;

module if_id_reg
(
    input clk,
    input load,
	 input clear,
    input [16-1:0] pc_in, ir_in,
    output logic [16-1:0] pc_out, ir_out
);

register #(.width(16)) ir (.*, .in(ir_in), .out(ir_out));
register #(.width(16)) pc (.*, .in(pc_in), .out(pc_out));

lc3b_opcode operation;
assign operation = lc3b_opcode'(ir_out[15:12]);

endmodule : if_id_reg
