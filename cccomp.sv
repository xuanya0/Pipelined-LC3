module cccomp #(parameter width = 3)
(
	input [width-1:0] a, b,
	output logic br_enb
);

always_comb
begin
	if ((a & b) == 0)
	br_enb = 0;
	else
	br_enb = 1;
end
endmodule : cccomp