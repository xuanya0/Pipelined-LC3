module mux4 #(parameter width = 16)
(
	input [1:0]sel,
	input [width-1:0] a, b, c, d,
	output logic [width-1:0] f
);

always_comb
begin
	f = a;

	if (sel == 2'b00) f = a;
	if (sel == 2'b01) f = b;
	if (sel == 2'b10) f = c;
	if (sel == 2'b11) f = d;
end
endmodule : mux4