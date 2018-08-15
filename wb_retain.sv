import lc3b_types::*;

module wb_retain
(
    input clk,
    input load,
	 input clear,
    input [2:0] reg_sel,
	 output logic [2:0] reg_sel_0, reg_sel_1,
	 input [16-1:0] reg_in,
	 output logic [16-1:0] reg_out_0, reg_out_1
);

//register 0 -- 4 might be enough

register #(.width( 3)) wb_sel_0 (.*, .in(reg_sel  ), .out(reg_sel_0));
register #(.width( 3)) wb_sel_1 (.*, .in(reg_sel_0), .out(reg_sel_1));

register #(.width(16)) wb_out_0 (.*, .in(reg_in   ), .out(reg_out_0));
register #(.width(16)) wb_out_1 (.*, .in(reg_out_0), .out(reg_out_1));

endmodule : wb_retain
