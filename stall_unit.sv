import lc3b_types::*;

module stall_unit
(
	input lc3b_word if_id_ir, id_ex_ir, ex_mem_ir,
	
	input branch_taken,
	
	//if stage
	input ir_read,  ir_write,  ir_resp,
	//mem stage
	input data_read, data_write, data_resp,
	
	output logic clear_if_id, clear_id_ex, clear_ex_mem, clear_mem_wb,
	
	output logic stall_pc, stall_if_id, stall_id_ex, stall_ex_mem, stall_mem_wb
);

logic [3:0] stall_num;

always_comb
begin
	//stalling order must strictly be 0 then 1 then 11 then 2 then 3 then 4 then 5
	stall_num = 0;
	
	//accessing IR memory
	if ((ir_read || ir_write) && !ir_resp)
		stall_num = 1;
	
	//branch handling with no prediction 
	//comment out this part for prediction to work
	/*
	if (((if_id_ir[15:12]==op_br) && (if_id_ir[11:9] != 3'b0)) || 
		 ((id_ex_ir[15:12]==op_br) && (id_ex_ir[11:9]!=3'b0)) ||
		 ((ex_mem_ir[15:12]==op_br) && (ex_mem_ir[11:9]!=3'b0)))
		stall_num = 1;
		
	if ((ex_mem_ir[15:12]==op_br) && (ex_mem_ir[11:9]!=3'b0) && branch_taken)
		stall_num = 11;
	*/
	
	//jmp handling
	if ((if_id_ir[15:12]==op_jmp) || (id_ex_ir[15:12]==op_jmp) || (ex_mem_ir[15:12]==op_jmp))
		stall_num = 11;
		
	//trap handling
	if ((if_id_ir[15:12]==op_trap) || (id_ex_ir[15:12]==op_trap) || (ex_mem_ir[15:12]==op_trap))
		stall_num = 11;
	
	//jsr handling
	if ((if_id_ir[15:12]==op_jsr) || (id_ex_ir[15:12]==op_jsr) || (ex_mem_ir[15:12]==op_jsr))
		stall_num = 11;
	
	
	//accessing instruction memory
	if ((ir_read || ir_write) && !ir_resp)
		stall_num = 11;
		
		
	//load from mem hazard
	if (((ex_mem_ir[15:12] == op_ldb) || (ex_mem_ir[15:12] == op_ldi) || (ex_mem_ir[15:12] == op_ldr)) &&
	(id_ex_ir[15:12] != op_br) && !(id_ex_ir[11] && (id_ex_ir[15:12] == op_jsr)) && (id_ex_ir[15:12] != op_lea) && (id_ex_ir[15:12] != op_rti) && (id_ex_ir[15:12] != op_trap) &&
	((ex_mem_ir[11:9] == id_ex_ir[8:6]) ||	((ex_mem_ir[11:9] == id_ex_ir[2:0]) && !id_ex_ir[5] && ((id_ex_ir[15:12] == op_add) || (id_ex_ir[15:12] == op_and)))))
		stall_num = 3;
		
	//accessing data memory
	if ((data_read || data_write) && !data_resp)
		stall_num = 4;

		
	// stall the whole thing to make things very simple
	if (((ir_read || ir_write) && !ir_resp) || ((data_read || data_write) && !data_resp))
		stall_num = 5;

end


// stalling
always_comb
begin
	stall_pc = 0;
	stall_if_id = 0;	clear_if_id = 0;
	stall_id_ex = 0;	clear_id_ex = 0;	
	stall_ex_mem = 0;	clear_ex_mem = 0;
	stall_mem_wb = 0;	clear_mem_wb = 0;
	
	

	case (stall_num)
		1: //if_stage    IR mem accessing
		begin
			stall_pc = 1;
			clear_if_id = 1;
		end
		11: //if_stage   BR resolving
		begin
			//stall_pc = 1;
			clear_if_id = 1;
		end
		2: //id_stage
		begin
			stall_pc = 1;
			stall_if_id = 1;
			clear_id_ex = 1;
		end
		3: //ex_stage
		begin
			stall_pc = 1;
			stall_if_id = 1;
			stall_id_ex = 1;
			clear_ex_mem = 1;
		end
		4: //mem_stage
		begin
			stall_pc = 1;
			stall_if_id = 1;
			stall_id_ex = 1;
			stall_ex_mem = 1;
			clear_mem_wb = 1;
		end
		5: //wb_stage
		begin
			stall_pc = 1;
			stall_if_id = 1;
			stall_id_ex = 1;
			stall_ex_mem = 1;
			stall_mem_wb = 1;
		end
		default: if (stall_num) $display("Unknown stall_num");
	endcase
	
end





endmodule : stall_unit
