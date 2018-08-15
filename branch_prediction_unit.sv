import lc3b_types::*;

module branch_prediction_unit
(
	input clk, stall, if_taken,
	input [16-1:0] source_pc, target_pc, source_ir, from_source,
	
	
	output [16-1:0]  to_target,
	output take_branch
);

logic true_branch;
logic [3:1] line_sel;

always_comb
begin
	true_branch = 0;
	if ((source_ir[15:12]==0) && (source_ir[11:9] != 0))
		true_branch = 1;
	
	line_sel = source_pc[3:1];
end

logic [16-1:0] array_src_pc, array_tgt_pc, array_from_source;

dp_array #(.width(16)) source_pc_array
(.*, .write(true_branch && (source_pc != array_src_pc) && !stall), 
.index(line_sel), .index_2(from_source[3:1]), .datain(source_pc), .dataout(array_src_pc), .dataout_2(array_from_source));

dp_array #(.width(16)) target_pc_array
(.*, .write(true_branch && (source_pc != array_src_pc) && !stall), 
.index(line_sel), .index_2(from_source[3:1]), .datain(target_pc), .dataout(array_tgt_pc), .dataout_2(to_target));

logic [1:0] array_hist_in, array_hist_out;

always_comb
begin
	array_hist_in = array_hist_out;
	if (source_pc == array_src_pc)
	begin
		if ((if_taken) && (array_hist_out != 2'b11))
			array_hist_in = array_hist_out+1;
		if ((!if_taken) && (array_hist_out != 2'b00))
			array_hist_in = array_hist_out-1;
	end
	if (source_pc != array_src_pc)
		array_hist_in = 2'b10;
end

logic [1:0] prediction;

dp_array #(.width(2)) branch_history
(.*, .write(true_branch && !stall), 
.index(line_sel), .index_2(from_source[3:1]), .datain(array_hist_in), .dataout(array_hist_out), .dataout_2(prediction));

assign take_branch = prediction[1] && (from_source==array_from_source);

endmodule: branch_prediction_unit