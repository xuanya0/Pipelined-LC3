module decode_mux #(parameter width = 16)
(
	input sel_1, sel_2, sel_3, sel_4, sel_5, sel_6, sel_7,
	input [width-1:0] in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7,
	output logic [width-1:0] out
);

always_comb
begin
	out = in_0;
	if (sel_1)
	out = in_1;
	if (sel_2)
	out = in_2;
	if (sel_3)
	out = in_3;
	if (sel_4)
	out = in_4;
	if (sel_5)
	out = in_5;
	if (sel_6)
	out = in_6;
	if (sel_7)
	out = in_7;
end
endmodule : decode_mux