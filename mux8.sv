module mux8 #(parameter width = 16)
(
	input [2:0] sel,
	input [width-1:0] a, b, c, d, e, f, g, h,
	output logic [width-1:0] out
);

always_comb
begin
	
	case(sel)
	0: out = a;
	1: out = b;
	2: out = c;
	3: out = d;
	4: out = e;
	5: out = f;
	6: out = g;
	7: out = h;
	default: out = a;
	endcase
end
endmodule : mux8