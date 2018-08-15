import lc3b_types::*;

module forwarding_to_ex
(
	input [2:0] wb_reg_sel_0, wb_reg_sel_1,
	input [16-1:0] wb_reg_out_0, wb_reg_out_1,
	
	// original data, good for no hazard
	input lc3b_word id_ex_ir,
	input lc3b_word Data1_in, Data2_in,

	// hazard linked to 1st previous ISA
	input lc3b_word ex_mem_ir,
	input lc3b_word ex_alu_data,
	
	// hazard linked to 2nd previous ISA
	input lc3b_word mem_wb_ir,
	input lc3b_word mem_wb_data,
	
	output lc3b_word Data1_out, Data2_out

);

logic [2:0] Reg1_sel, Reg2_sel;
logic [3:0] fwd_num;

//what are the source registers that need data earlier
always_comb
begin
	Reg1_sel = id_ex_ir[8:6];
	Reg2_sel = id_ex_ir[2:0];
	//handle the stupid Store Instructions
	if ((id_ex_ir[15:12] == op_stb) || (id_ex_ir[15:12] == op_sti) || (id_ex_ir[15:12] == op_str))
		Reg2_sel = id_ex_ir[11:9];
end

always_comb
begin
	
	//default: WB stage
	Data1_out = Data1_in;
	Data2_out = Data2_in;
	fwd_num = 0;
	

	if(wb_reg_sel_1 == Reg1_sel)
		Data1_out = wb_reg_out_1;
	if(wb_reg_sel_1 == Reg2_sel)
		Data2_out = wb_reg_out_1;
	if ((wb_reg_sel_1 == Reg1_sel) || (wb_reg_sel_1 == Reg2_sel))
		fwd_num = 4;
		
	if(wb_reg_sel_0 == Reg1_sel)
		Data1_out = wb_reg_out_0;
	if(wb_reg_sel_0 == Reg2_sel)
		Data2_out = wb_reg_out_0;
	if ((wb_reg_sel_0 == Reg1_sel) || (wb_reg_sel_0 == Reg2_sel))
		fwd_num = 3;
		
	//MEM stage forwarding
	if ((mem_wb_ir[15:12] == op_add) ||
		(mem_wb_ir[15:12] == op_and) ||
		(mem_wb_ir[15:12] == op_ldb) ||
		(mem_wb_ir[15:12] == op_ldi) ||
		(mem_wb_ir[15:12] == op_ldr) ||
		(mem_wb_ir[15:12] == op_lea) ||
		(mem_wb_ir[15:12] == op_not) ||
		(mem_wb_ir[15:12] == op_shf))
	begin
		if (mem_wb_ir[11:9] == Reg1_sel)
			Data1_out = mem_wb_data;
		if (mem_wb_ir[11:9] == Reg2_sel)
			Data2_out = mem_wb_data;
		if ((mem_wb_ir[11:9] == Reg1_sel) || (mem_wb_ir[11:9] == Reg2_sel))
			fwd_num = 2;
	end
	//EX stage forwarding : mem_load not yet resolved, but stalling unit will handle this
	if ((ex_mem_ir[15:12] == op_add) ||
		(ex_mem_ir[15:12] == op_and) ||
		(ex_mem_ir[15:12] == op_lea) ||
		(ex_mem_ir[15:12] == op_not) ||
		(ex_mem_ir[15:12] == op_shf))
	begin
		if (ex_mem_ir[11:9] == Reg1_sel)
			Data1_out = ex_alu_data;
		if (ex_mem_ir[11:9] == Reg2_sel)
			Data2_out = ex_alu_data;
		if ((ex_mem_ir[11:9] == Reg1_sel) || (ex_mem_ir[11:9] == Reg2_sel))
			fwd_num = 1;
	end
	

end

endmodule : forwarding_to_ex