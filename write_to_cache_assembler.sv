import lc3b_types::*;

module write_to_cache_assembler 
(
	 input lc3b_word mem_wdata,
	 input [3:0] mem_offset,
	 input [1:0] mem_byte_enable,
	 input [127:0] burst_mux_out,
	 output logic [127:0] assembler_out
);


int unsigned offset;

always_comb
begin

assembler_out = burst_mux_out;

offset = mem_offset[3:1];

	case(offset)
	0:
	begin
	if (mem_byte_enable[0])
		assembler_out[7:0] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[15:8] = mem_wdata[15:8];
	end
	
	1:
	begin
	if (mem_byte_enable[0])
		assembler_out[23:16] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[31:24] = mem_wdata[15:8];
	end
	
	2:
	begin
	if (mem_byte_enable[0])
		assembler_out[39:32] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[47:40] = mem_wdata[15:8];
	end
	
	3:
	begin
	if (mem_byte_enable[0])
		assembler_out[55:48] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[63:56] = mem_wdata[15:8];
	end
	
	4:
	begin
	if (mem_byte_enable[0])
		assembler_out[71:64] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[79:72] = mem_wdata[15:8];
	end
	
	5:
	begin
	if (mem_byte_enable[0])
		assembler_out[87:80] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[95:88] = mem_wdata[15:8];
	end
	
	6:
	begin
	if (mem_byte_enable[0])
		assembler_out[103:96] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[111:104] = mem_wdata[15:8];
	end
	
	7:
	begin
	if (mem_byte_enable[0])
		assembler_out[119:112] = mem_wdata[7:0];
	if (mem_byte_enable[1])
		assembler_out[127:120] = mem_wdata[15:8];
	end
	
	endcase
	

end




endmodule: write_to_cache_assembler 