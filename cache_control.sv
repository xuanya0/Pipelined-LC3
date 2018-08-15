import lc3b_types::*;

module cache_control
(
	input  clk,
	input  pmem_resp,
	input  [1:0] hit,
	input  dirty,  // from dirty mux_ou
	input  mem_write,
	input  mem_read,
	input  lru_out,
	
	output logic tag_write  ,
	output logic valid_write,
	output logic dirty_set  ,
	output logic dirty_reset,
	output logic retain     ,
	output logic mem_resp   ,
	output logic pmem_read  ,
	output logic pmem_write ,
	output logic lru_write  ,  // bit flipping
	output logic pmem_addr_sel,
	output logic save_to_cache_sel
);

enum int unsigned 
{
	ready,
	read_from_mem,
	got_from_mem,
	update_mem
	
}state, next_state;

always_comb
begin : state_actions

	tag_write  = 0;
	valid_write= 0;
	dirty_set  = 0;
	dirty_reset= 0;
	retain     = 0;
	mem_resp   = 0;
	pmem_read  = 0;
	pmem_write = 0;
	lru_write  = 0;
	pmem_addr_sel = 0;
	save_to_cache_sel = 0;
	
	case(state)
	ready:
	begin
		//write
		if (mem_write && hit)
		begin
			mem_resp = 1;
			dirty_set = 1;
			save_to_cache_sel = 1;
			if ((hit[1] && lru_out) || (hit[0] && !lru_out)) //if LRU == hit, flip!
				lru_write=1;
		end
		//read
		if (mem_read && hit)
		begin
			mem_resp = 1;
			if ((hit[1] && lru_out) || (hit[0] && !lru_out)) //if LRU == hit, flip!
				lru_write=1;
		end
	
	end
	//reading from physical memory // no hit for both read/write
	read_from_mem:
	begin
		pmem_read = 1;
	end
	got_from_mem:
	begin
		mem_resp = 1;  // got so resp
		valid_write = 1;
		dirty_reset = 1;
		tag_write = 1;
		lru_write = 1; // flip the bit so it points to the other array
		if (dirty)     // retain for whatever reasons
			retain = 1;
		if (mem_write)  // because write
		begin
			dirty_set = 1;
			save_to_cache_sel = 1;
		end
	end
	//writing back to physical memory
	update_mem:
	begin
		pmem_write = 1;
		pmem_addr_sel = 1;
		// copy from mem_ready
		if (mem_write && hit)
		begin
			mem_resp = 1;
			dirty_set = 1;
			save_to_cache_sel = 1;
			if ((hit[1] && lru_out) || (hit[0] && !lru_out)) //if LRU == hit, flip!
				lru_write=1;
		end
		//read
		if (mem_read && hit)
		begin
			mem_resp = 1;
			if ((hit[1] && lru_out) || (hit[0] && !lru_out)) //if LRU == hit, flip!
				lru_write=1;
		end
	end
	endcase
	
	


end

always_comb
begin : next_state_logic

	case(state)
		ready:
		begin
		if ((mem_write || mem_read) && !hit)
			next_state <= read_from_mem;
		else
			next_state <= ready;
		end
		//miss, have to get from memory, whether read/write
		read_from_mem:
		begin
		if (pmem_resp)
			next_state <= got_from_mem;
		else
			next_state <= read_from_mem;
		end
		//just got from memory 
		got_from_mem:
		begin
		if (dirty)
			next_state <= update_mem;
		else
			next_state <= ready;
		end
		//write to memory because of dirty
		update_mem:
		begin
		if (pmem_resp)
			next_state <= ready;
		else
			next_state <= update_mem;
		end
	endcase

end


always_ff @(posedge clk)
begin: next_state_assignment
	/* Assignment of next state on clock edge */
	state <= next_state;
end

endmodule: cache_control