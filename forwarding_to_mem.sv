import lc3b_types::*;

module forwarding_to_mem
(
	input load_regfile,
	input [16-1:0] data_in, mem_wb_reg_data, ex_mem_ir, mem_wb_ir,	
	
	input [2:0] wb_reg_sel_0, wb_reg_sel_1,
	input [16-1:0] wb_reg_out_0, wb_reg_out_1,
	output logic [16-1:0] data_out
);

logic [1:0] fwd_num;

always_comb
begin
	
	data_out = data_in;
	fwd_num = 0;
	
	if (ex_mem_ir[11:9]==wb_reg_sel_1)
	begin
		data_out = wb_reg_out_1;
		fwd_num = 3;
	end
	
	if (ex_mem_ir[11:9]==wb_reg_sel_0)
	begin
		data_out = wb_reg_out_0;
		fwd_num = 2;
	end
	
	if ((ex_mem_ir[11:9]==mem_wb_ir[11:9]) && load_regfile)
	begin
		data_out = mem_wb_reg_data;
		fwd_num = 1;
	end

end

endmodule : forwarding_to_mem