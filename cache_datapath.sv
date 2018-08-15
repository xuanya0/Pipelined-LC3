import lc3b_types::*;

module cache_datapath
(
	input clk,
	input lc3b_word mem_address,
	input [1:0] mem_byte_enable,
	input tag_write,
	input retain,
	input mem_write,
	input dirty_set,
	input dirty_reset,
	input lru_write,
	input valid_write,
	input pmem_addr_sel,
	input save_to_cache_sel,
	
	input [15:0] mem_wdata,
	input [127:0] pmem_rdata,
	
	output logic lru_out,
	output logic dirty_mux_out,
	output logic [1:0] hit,
	output logic [15:0] pmem_address,
	output logic [15:0] mem_rdata,
	output logic [127:0] pmem_wdata	
);

/*
module array #(parameter width = 128)
(
    input clk,
    input write,
    input [2:0] index,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);
 logic mem_resp;
 lc3b_word mem_rdata;
 logic mem_read;
 logic mem_write;
 lc3b_mem_wmask mem_byte_enable;
 lc3b_word mem_address;
 lc3b_word mem_wdata;
*/
logic [127:0] assembler_out;
logic [127:0] cache_line_in;
logic [127:0] line_retain_mux_out;
logic [15:7] tag_in, tag0_out, tag1_out, tag_mux_out;
assign tag_in = mem_address[15:7];
logic [6:4] set_sel;
assign set_sel = mem_address[6:4];
logic [3:0] mem_offset;
assign mem_offset = mem_address[3:0];
//logic dirty_mux_out;

logic [15:0] address_retainer_out;


array #(.width(9))tag_array_0 
(
.clk,
.write(!lru_out && tag_write),
.index(set_sel),
.datain(tag_in),
.dataout(tag0_out)
);
array #(.width(9)) tag_array_1
(
.clk,
.write(lru_out && tag_write),
.index(set_sel),
.datain(tag_in),
.dataout(tag1_out)
);

logic tag0_cmp,tag1_cmp, valid0_out, valid1_out;
always_comb
begin
	tag0_cmp=0;
	tag1_cmp=0;
	if ((tag0_out == tag_in) && (valid0_out)) tag0_cmp = 1;
	if ((tag1_out == tag_in) && (valid1_out)) tag1_cmp = 1;
	
	hit = {tag1_cmp,tag0_cmp};
end

mux2 #(.width(128)) write_to_cache_line_mux 
(
.sel(save_to_cache_sel),
.a(pmem_rdata),
.b(assembler_out),
.f(cache_line_in)
);

logic [127:0] cdata0_out;
array #(.width(128)) data_array_0
(
.clk,
.write((!lru_out && tag_write) || (mem_write && hit[0])),
.index(set_sel),
.datain(cache_line_in),
.dataout(cdata0_out)
);

logic [127:0] cdata1_out;
array #(.width(128)) data_array_1
(
.clk,
.write(lru_out && tag_write || (mem_write && hit[1])),
.index(set_sel),
.datain(cache_line_in),
.dataout(cdata1_out)
);


logic [127:0] burst_mux_out;
mux4 #(.width(128)) cache_line_pmem_mux
(
.sel({tag1_cmp,tag0_cmp}),
.a(pmem_rdata), 
.b(cdata0_out), // 01
.c(cdata1_out), // 10
.d(pmem_rdata),
.f(burst_mux_out)
);

mux8 cache128_to_mem16
(
.sel(mem_offset[3:1]),
.h(burst_mux_out[127:112]),.g(burst_mux_out[111:96]),.f(burst_mux_out[95:80]),.e(burst_mux_out[79:64]),
.d(burst_mux_out[63:48]),.c(burst_mux_out[47:32]),.b(burst_mux_out[31:16]),.a(burst_mux_out[15:0]),
.out(mem_rdata)
);

array  #(.width(1)) lru_reg
(
.clk,
.write(lru_write),
.index(set_sel),
.datain(~lru_out), // bit flipping
.dataout(lru_out)
);

array #(.width(1)) valid0_reg
(
.clk,
.write(!lru_out && valid_write),
.index(set_sel),
.datain(1'b1),//set validva
.dataout(valid0_out)
);

array #(.width(1)) valid1_reg
(
.clk,
.write(lru_out && valid_write),
.index(set_sel),
.datain(1'b1),//set valid
.dataout(valid1_out)
);

logic dirty0_out, dirty1_out;
SR_array dirty0_reg
(
.clk,
.set(dirty_set),
.reset(dirty_reset),
.enable((hit[0] && mem_write) || (!lru_out && tag_write)),
.index(set_sel),
.dataout(dirty0_out)
);

SR_array dirty1_reg
(
.clk,
.set(dirty_set),
.reset(dirty_reset),
.enable((hit[1] && mem_write) || (lru_out && tag_write)),
.index(set_sel),
.dataout(dirty1_out)
);


mux2 #(.width(1)) dirty_mux
(
.sel(lru_out),
.a(dirty0_out),
.b(dirty1_out),
.f(dirty_mux_out)
);

mux2 #(.width(9)) tag_mux
(
.sel(lru_out),
.a(tag0_out),
.b(tag1_out),
.f(tag_mux_out)
);


register #(.width(16)) cache_address_retainer
(
.clk,
.load(retain),
.clear(0),
.in({tag_mux_out,set_sel,4'b0}),
.out(address_retainer_out)
);
/*
register dirty_bit_retainer#(width = 1)
(
.clk,
.load(),
.in(dirty_mux_out),
.out(),
);
*/
mux2 #(.width(128)) line_retain_mux
(
.sel(lru_out),
.a(cdata0_out),
.b(cdata1_out),
.f(line_retain_mux_out)
);
register #(.width(128)) cache_line_retainer
(
.clk,
.load(retain),
.clear(0),
.in(line_retain_mux_out),
.out(pmem_wdata)
);


write_to_cache_assembler write_to_cache_assembler_1
(
.mem_offset,
.mem_wdata,
.mem_byte_enable,
.burst_mux_out,
.assembler_out(assembler_out)
);

mux2 #(.width(16)) pmem_addr_mux
(
.sel(pmem_addr_sel),
.a(mem_address),
.b(address_retainer_out),
.f(pmem_address)
);



endmodule : cache_datapath