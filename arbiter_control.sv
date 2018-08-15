import lc3b_types::*;

module arbiter_control
(
	input logic clk,
	input logic pmem_read_b, pmem_write_b, pmem_resp, pmem_read_a,
	output logic arbiter_sel
);

enum int unsigned {
	init, i_cache, d_cache
} state, next_state;

always_comb begin: state_actoins
	arbiter_sel = 0;
	case(state)
		init: if(pmem_read_b == 1 || pmem_write_b == 1) arbiter_sel = 1;
		i_cache: arbiter_sel = 1;
		d_cache: arbiter_sel = 0;
		default:;
	endcase
end


always_comb begin: next_state_logic
	case(state)
		init: begin
			if(pmem_read_b == 1 || pmem_write_b == 1)
				next_state = d_cache;
			else if(pmem_read_a == 1)
				next_state = i_cache;
			else
				next_state = init;
		end
		d_cache: begin
			if(pmem_resp == 1) next_state = init;
			else next_state = d_cache;
		end
		i_cache: begin
			if(pmem_resp == 1) next_state = init;
			else next_state = i_cache;
		end
		default:;
	endcase
end

always_ff @(posedge clk) begin : next_state_assignment
    state <= next_state;
end

endmodule : arbiter_control