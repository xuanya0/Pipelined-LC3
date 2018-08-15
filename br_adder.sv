import lc3b_types::*;

module br_adder
(
	input [8:0] offset9,
	input lc3b_word pc,
	output lc3b_word br_adder_out
);



always_comb 
	begin
		br_adder_out = $signed({offset9, 1'b0});
		br_adder_out +=pc;
	end
endmodule : br_adder