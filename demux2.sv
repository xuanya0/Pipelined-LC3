module demux2 #(parameter width = 16)
(
	input sel,
	input [width-1:0] in,
	output logic [width-1:0] out1, out2
);

always_comb
begin
	if (sel == 0) begin
		out1 = in;
		out2 = 0;
	end
	else begin
		out1 = 0;
		out2 = in;
	end
end
endmodule : demux2