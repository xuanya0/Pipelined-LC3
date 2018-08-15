import lc3b_types::*;

module arbiter
(
	 input clk,
	 
	 output pmem_resp_a, pmem_resp_b,

	 input logic pmem_write_b,
	 input logic pmem_read_a, pmem_read_b,
	 
	 input logic [127:0] pmem_wdata_b,
	 output logic [127:0] pmem_rdata_a, pmem_rdata_b,
	 
	 input logic [15:0] pmem_address_a, pmem_address_b,
	 /* Memory signals */


	 input pmem_resp,

	 output logic pmem_write,
	 output logic pmem_read,
	 
	 output logic [127:0] pmem_wdata,
	 input logic [127:0] pmem_rdata,
	 
	 output logic [15:0] pmem_address	
);
logic arbiter_sel;
assign pmem_rdata_a = pmem_rdata;
assign pmem_rdata_b = pmem_rdata;
assign pmem_wdata = pmem_wdata_b;
assign pmem_write = pmem_write_b;

mux2 #(.width(16)) cache_addr_mux
(
	.sel(arbiter_sel),
	.a(pmem_address_a),
	.b(pmem_address_b),
	.f(pmem_address)
);

mux2 #(.width(1)) cache_read_mux
(
	.sel(arbiter_sel),
	.a(pmem_read_a),
	.b(pmem_read_b),
	.f(pmem_read)
);

demux2 #(.width(1)) cache_resp_demux
(
	.sel(arbiter_sel),
	.in(pmem_resp),
	.out1(pmem_resp_a),
	.out2(pmem_resp_b)
);


arbiter_control arbiter_control
(
	.*
);

endmodule: arbiter