import lc3b_types::*;

module cache
(
	 input clk,

	 /* Memory signals */
	 output logic mem_resp,

	 input pmem_resp,
	 input mem_read,
	 input mem_write,
	 output logic pmem_write,
	 output logic pmem_read,
	 
	 input lc3b_mem_wmask mem_byte_enable,
	 input lc3b_word mem_address,
	 input lc3b_word mem_wdata,
	 
	 output lc3b_word mem_rdata,
	 
	 output logic [127:0] pmem_wdata,
	 input  [127:0] pmem_rdata,
	 
	 output logic [15:0] pmem_address
	 
);

logic tag_write  ;
logic valid_write;
logic dirty_set  ;
logic dirty_reset;
logic retain     ;
logic lru_write  ;
logic lru_out    ;

logic [1:0] hit  ;
logic dirty      ;
logic pmem_addr_sel;
logic save_to_cache_sel;

cache_control cache_control_1
(
.*
);

cache_datapath cache_datapath_1
(
.*,
.dirty_mux_out(dirty)
);
endmodule: cache