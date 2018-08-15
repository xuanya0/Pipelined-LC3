import lc3b_types::*;

module jsr_adder
(
	input [10:0] offset11,
	input lc3b_word pc,
	output lc3b_word out
);



always_comb 
	begin
		out = $signed({offset11, 1'b0});
		out +=pc;
	end
endmodule : jsr_adder