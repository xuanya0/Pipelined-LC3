import lc3b_types::*;

module opcode_decoder
(
	input [15:0] IR,
	output ctrl_struct ctrl_signal
);

logic [3:0] opcode;
assign opcode = IR[15:12];

always_comb
begin
	ctrl_signal.load_pc = 0;
	ctrl_signal.load_ir = 0;
	ctrl_signal.load_regfile = 0;
	ctrl_signal.aluop = alu_add;
	ctrl_signal.mem_read = 0;
	ctrl_signal.mem_write = 0;
	ctrl_signal.mem_byte_enable = 0;
	ctrl_signal.storemux_sel = 0;
	ctrl_signal.alumux_sel = 0;
	ctrl_signal.regfilemux_sel = 0;
	ctrl_signal.load_cc = 0;
	ctrl_signal.pcsr1mux_sel = 0;
	ctrl_signal.imm5mux_sel = 0;
	ctrl_signal.leamux_sel = 0;
	ctrl_signal.offset6mux_sel = 0;
	ctrl_signal.mdr_to_mar = 0;
	ctrl_signal.jsr_sel = 0;
	ctrl_signal.trap_sel = 0;
	ctrl_signal.trapmux_sel = 0;
	ctrl_signal.stb_high_byte_sel = 0;
	ctrl_signal.gccmux_sel = 0;
	ctrl_signal.jsr_direct = 0;
	ctrl_signal.imm4mux_sel = 0;
	ctrl_signal.byte_access = 0;
	ctrl_signal.pcmux_sel = 0;
	ctrl_signal.mem_indirect = 0;

	case (opcode)
		op_add:
		begin
			ctrl_signal.aluop = alu_add;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.regfilemux_sel = 0;
			ctrl_signal.load_cc = 1;
			if(IR[5])
				ctrl_signal.imm5mux_sel = 1;
		end
		op_and:
		begin
			ctrl_signal.aluop = alu_and;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.load_cc = 1;
			if(IR[5])
				ctrl_signal.imm5mux_sel = 1;
		end
		op_br:
		begin
			ctrl_signal.load_pc = 1;
		end
		op_jmp:              /* also RET */
		begin
			ctrl_signal.aluop = alu_pass;
			ctrl_signal.load_pc = 1;
		end
		op_jsr:              /* also JSRR */
		begin
			ctrl_signal.aluop = alu_pass;
			ctrl_signal.load_regfile = 1;
			if (IR[11])
					ctrl_signal.jsr_direct = 1;
		end
		op_ldb:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.mem_read = 1;
			ctrl_signal.regfilemux_sel = 1;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.gccmux_sel = 1;
			ctrl_signal.load_cc = 1;
			
			ctrl_signal.byte_access = 1;
		end
		op_ldi:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.mem_read = 1;
			ctrl_signal.regfilemux_sel = 1;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.gccmux_sel = 1;
			ctrl_signal.load_cc = 1;
			
			ctrl_signal.mem_indirect = 1;
		end
		op_ldr:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.mem_read = 1;
			ctrl_signal.regfilemux_sel = 1;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.gccmux_sel = 1;
			ctrl_signal.load_cc = 1;
		end
		op_lea:
		begin
			ctrl_signal.load_regfile = 1;
			ctrl_signal.load_cc = 1;
		end
		op_not:
		begin
			ctrl_signal.aluop = alu_not;
			ctrl_signal.load_regfile = 1;
			ctrl_signal.load_cc = 1;
		end
		op_rti:
		begin
		end
		op_shf:
		begin
			ctrl_signal.imm4mux_sel = 1;
			if (IR[4] == 0)
				ctrl_signal.aluop = alu_sll;
			if (IR[4] && !IR[5])
				ctrl_signal.aluop = alu_srl;
			if (IR[4] && IR[5])
				ctrl_signal.aluop = alu_sra;
				
			ctrl_signal.load_regfile = 1;
			ctrl_signal.load_cc = 1;
		end
		op_stb:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.storemux_sel = 1;
			ctrl_signal.mem_write = 1;
			//ctrl_signal.mem_byte_enable = 2'b01;
			
			ctrl_signal.byte_access = 1;			
		end
		op_sti:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.storemux_sel = 1;
			ctrl_signal.mem_write = 1;
			//ctrl_signal.mem_byte_enable = 2'b11;
			
			ctrl_signal.mem_indirect = 1;
		end
		op_str:
		begin
			ctrl_signal.alumux_sel = 1;
			ctrl_signal.aluop = alu_add;  // calculate address
			ctrl_signal.storemux_sel = 1;
			ctrl_signal.mem_write = 1;
			//ctrl_signal.mem_byte_enable = 2'b11;
		end
		op_trap:
		begin
			ctrl_signal.mem_read = 1;
			ctrl_signal.load_regfile = 1;
		end
	endcase

end






endmodule : opcode_decoder
