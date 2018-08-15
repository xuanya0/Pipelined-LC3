import lc3b_types::*;

module cpu
(
    input clk,

    /* Port A */
    output logic read_a,
    output logic write_a,
    output logic [1:0] wmask_a,
    output logic [15:0] address_a,
    output logic [15:0] wdata_a,
    input resp_a,
    input [15:0] rdata_a,

    /* Port B */
    output logic read_b,
    output logic write_b,
    output logic [1:0] wmask_b,
    output logic [15:0] address_b,
    output logic [15:0] wdata_b,
    input resp_b,
    input[15:0] rdata_b
);

assign wmask_a = 0;
assign wdata_a = 0;
assign write_a = 0;

logic [1:0] wmask_mux_out;

logic [15:0]
c_rdata_b, trap_mux_out, mem_read_mux_out, mem_write_mux_out, ex_DR_val, 

if_id_ir_out, id_ex_ir_out, ex_mem_ir_out, mem_wb_ir_out, 
if_id_pc_out, id_ex_pc_out, ex_mem_pc_out, mem_wb_pc_out,
jsr_adder_out, jsrmux_out,
sr1_out, sr2_out, regfilemux_out, fwd_data1, fwd_data2, fwd_to_mem_data,
id_ex_sr1_out, id_ex_sr2_out,
ex_mem_sr1_out, ex_mem_sr2_out,

pc_reg_out, pcmux_out, adj6_out, alumux_out, alu_out, br_dest, mem_wb_br_dest_out,
ex_mem_alu_out, mem_wb_mem_out, mem_wb_alu_out;
logic [7:0] ldb_mux_out;
logic [2:0] storemux_out, alu_cc, mem_cc, ex_mem_alu_nzp_out, gccmux_out, destReg_mux_out, cc_out, lea_cc, ex_CC_val;
logic branch_taken, c_resp_b;

logic [2:0] wb_reg_sel_0, wb_reg_sel_1;
logic [16-1:0] wb_reg_out_0, wb_reg_out_1;

ctrl_struct decoder_out, id_ex_ctrl_out, ex_mem_ctrl_out, mem_wb_ctrl_out;

//assign pipeline_stall = ((ex_mem_ctrl_out.mem_read || ex_mem_ctrl_out.mem_write) && (!c_resp_b)) || ((read_a || write_a) && (!resp_a));
logic clear_if_id, clear_id_ex, clear_ex_mem, clear_mem_wb,	stall_pc, stall_if_id, stall_id_ex, stall_ex_mem, stall_mem_wb;

stall_unit stall_unit(.if_id_ir(if_id_ir_out), .id_ex_ir(id_ex_ir_out), .ex_mem_ir(ex_mem_ir_out),
.branch_taken(branch_taken),
.ir_read(read_a), .ir_write(write_a),  .ir_resp(resp_a),
.data_read(ex_mem_ctrl_out.mem_read), .data_write(ex_mem_ctrl_out.mem_write), .data_resp(c_resp_b),	
.*);

//IF↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓IF↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓IF
logic [16-1:0] predict_addr, predict_mux_out;
logic predict_take;
logic mis_predict, cor_predict;

assign mis_predict = (ex_mem_ir_out[15:12]==0) && (ex_mem_ir_out[11:9]!=0) && //has to be a true branch
(((ex_mem_alu_out+2 != id_ex_pc_out) && branch_taken) || ((ex_mem_pc_out+2 != id_ex_pc_out) && !branch_taken));

assign cor_predict = (ex_mem_ir_out[15:12]==0) && (ex_mem_ir_out[11:9]!=0) && //has to be a true branch
(((ex_mem_alu_out+2 == id_ex_pc_out) && branch_taken) || ((ex_mem_pc_out+2 == id_ex_pc_out) && !branch_taken));



decode_mux #(.width(16)) pcmux(.in_0(pc_reg_out+2), .out(pcmux_out),
.sel_1((branch_taken && (ex_mem_ir_out[15:12] == op_br)) || (ex_mem_ir_out[15:12] == op_jmp)), .in_1(ex_mem_alu_out), 
.sel_2(ex_mem_ir_out[15:12]==op_jsr), .in_2(jsrmux_out), 
.sel_3(ex_mem_ir_out[15:12]==op_trap), .in_3(c_rdata_b), 
.sel_4(cor_predict), .in_4(pc_reg_out+2), 
.sel_5(mis_predict &&  branch_taken), .in_5(ex_mem_alu_out), 
.sel_6(mis_predict && !branch_taken), .in_6(ex_mem_pc_out), 
.sel_7(0), .in_7(0));
		  
mux2 #(.width(16)) predict_mux(.sel(predict_take && !mis_predict), .a(pcmux_out), .b(predict_addr), .f(predict_mux_out));
			  
register #(.width(16)) pc_reg (.*, .clear(0), .load(!stall_pc), .in(predict_mux_out), .out(pc_reg_out));
assign address_a = pc_reg_out;
assign read_a = 1;
//IF↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑IF↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑IF

if_id_reg if_id_reg_1 (.*, .clear(clear_if_id || mis_predict), .load(!stall_if_id), .ir_in(rdata_a), .pc_in(pc_reg_out+2), .ir_out(if_id_ir_out), .pc_out(if_id_pc_out));


//ID↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ID↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ID

mux2 #(.width(3)) storemux( .sel(decoder_out.storemux_sel), .a(if_id_ir_out[2:0]), .b(if_id_ir_out[11:9]), .f(storemux_out) ); // select source register

regfile regfile(.*, .load(mem_wb_ctrl_out.load_regfile), .dest(destReg_mux_out), .in(regfilemux_out), .src_a(if_id_ir_out[8:6]), .src_b(storemux_out), .reg_a(sr1_out), .reg_b(sr2_out));

opcode_decoder decoder(.IR(if_id_ir_out), .ctrl_signal(decoder_out));

//ID↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ID↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ID

id_ex_reg id_ex_reg(.*, .clear(clear_id_ex || mis_predict), .load(!stall_id_ex), 
.ir_in(if_id_ir_out), .pc_in(if_id_pc_out), .ctrl_in(decoder_out), .reg_a_in(sr1_out), .reg_b_in(sr2_out),
.ir_out(id_ex_ir_out),.pc_out(id_ex_pc_out),.ctrl_out(id_ex_ctrl_out), .reg_a_out(id_ex_sr1_out), .reg_b_out(id_ex_sr2_out));

//EX↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓EX↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓EX
forwarding_to_ex forwarding_to_ex(.*,
.id_ex_ir(id_ex_ir_out), .Data1_in(id_ex_sr1_out), .Data2_in(id_ex_sr2_out),
.ex_mem_ir(ex_mem_ir_out), .ex_alu_data(ex_mem_alu_out),
.mem_wb_ir(mem_wb_ir_out), .mem_wb_data(regfilemux_out),
.Data1_out(fwd_data1), .Data2_out(fwd_data2));



adj  #(.width(6)) adj6 (.in(id_ex_ir_out[5:0]), .out(adj6_out));
logic [15:0] sext_imm5, sext_imm6;
assign sext_imm5 = $signed(id_ex_ir_out[4:0]);
assign sext_imm6 = $signed(id_ex_ir_out[5:0]);
decode_mux #(.width(16)) alumux ( .sel_1(id_ex_ctrl_out.alumux_sel), .sel_2(id_ex_ctrl_out.imm5mux_sel), .sel_3(id_ex_ctrl_out.imm4mux_sel), .sel_4(id_ex_ctrl_out.byte_access), .sel_5(0), .sel_6(0), .sel_7(0),
				.in_0(fwd_data2), .in_1(adj6_out), .in_2(sext_imm5), .in_3({12'b0,id_ex_ir_out[3:0]}), .in_4(sext_imm6), .in_5(0), .in_6(0), .in_7(0), 
				.out(alumux_out) );

//resolve DR value				
alu ex_alu (.aluop(id_ex_ctrl_out.aluop), .a(fwd_data1), .b(alumux_out), .f(alu_out));
gencc alu_gencc (.in(alu_out), .out(alu_cc));

//resolve branch in EX, we need LEA
br_adder br_adder(.offset9(id_ex_ir_out[8:0]), .pc(id_ex_pc_out), .br_adder_out(br_dest));
gencc lea_gencc (.in(br_dest), .out(lea_cc));

mux2 #(.width(16)) dr_val_mux( .sel((id_ex_ir_out[15:12]==op_lea) || (id_ex_ir_out[15:12]==op_br)), .a(alu_out), .b(br_dest), .f(ex_DR_val) );
mux2 #(.width(3)) cc_mux( .sel(id_ex_ir_out[15:12]==op_lea), .a(alu_cc), .b(lea_cc), .f(ex_CC_val) );


//EX↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑EX↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑EX
ex_mem_reg ex_mem_reg(.*, .clear(clear_ex_mem || mis_predict), .load(!stall_ex_mem),  
.pc_in(id_ex_pc_out), .ir_in(id_ex_ir_out), .reg_a_in(fwd_data1), .reg_b_in(fwd_data2), 
.ctrl_in(id_ex_ctrl_out), .alu_nzp_in(ex_CC_val), .alu_in(ex_DR_val),

.pc_out(ex_mem_pc_out), .ir_out(ex_mem_ir_out), .reg_a_out(ex_mem_sr1_out), .reg_b_out(ex_mem_sr2_out), 
.ctrl_out(ex_mem_ctrl_out), .alu_nzp_out(ex_mem_alu_nzp_out), .alu_out(ex_mem_alu_out) );

//MEM↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓MEM↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓MEM
//                                                                                     PC = memWord[ZEXT(trapvect8) << 1];
mux2 #(.width(16)) trap_mux( .sel(ex_mem_ir_out[15:12]==op_trap), .a(ex_mem_alu_out), .b({7'b0,ex_mem_ir_out[7:0],1'b0}), .f(trap_mux_out) );

forwarding_to_mem forwarding_to_mem(.*, 
.load_regfile(mem_wb_ctrl_out.load_regfile), .mem_wb_reg_data(regfilemux_out), 
.data_in(ex_mem_sr2_out), .ex_mem_ir(ex_mem_ir_out), .mem_wb_ir(mem_wb_ir_out),
.data_out(fwd_to_mem_data));

mux2 #(.width(16)) mem_write_mux( .sel(ex_mem_ctrl_out.byte_access && trap_mux_out[0]), 
                                  .a(fwd_to_mem_data), .b({fwd_to_mem_data[7:0],8'b0}),
	                               .f(mem_write_mux_out) );


decode_mux #(.width(2)) wmask_mux( .sel_1(ex_mem_ctrl_out.byte_access && ~trap_mux_out[0]), .sel_2(ex_mem_ctrl_out.byte_access && trap_mux_out[0]), .sel_3(0), .sel_4(0), .sel_5(0), .sel_6(0), .sel_7(0),
                     .in_0(2'b11), .in_1(2'b01), .in_2(2'b10), .in_3(0), .in_4(0), .in_6(0), .in_7(0),
	                  .out(wmask_mux_out) );



//memory
mem_indirect mem_indirect
(.*, // cpu                                        //physical_mem
.stldi(ex_mem_ctrl_out.mem_indirect),              
.c_read_b(ex_mem_ctrl_out.mem_read),               .p_read_b(read_b),
.c_write_b(ex_mem_ctrl_out.mem_write),             .p_write_b(write_b),
.c_wmask_b(wmask_mux_out),                         .p_wmask_b(wmask_b),
.c_address_b(trap_mux_out),                        .p_address_b(address_b),
.c_wdata_b(mem_write_mux_out),                     .p_wdata_b(wdata_b),
.c_resp_b(c_resp_b),                               .p_resp_b(resp_b),
.c_rdata_b(c_rdata_b),                             .p_rdata_b(rdata_b)
);

//assign read_b = ex_mem_ctrl_out.mem_read;//  && ~clk; // delay by half cycle
//assign write_b = ex_mem_ctrl_out.mem_write;// && ~clk; // delay by half cycle
//assign wmask_b = ex_mem_ctrl_out.mem_byte_enable;
//assign address_b = ex_mem_alu_out;
//assign wdata_b = ex_mem_sr2_out;
//input resp_b,
//input[15:0] rdata_b
mux2 #(.width(8)) ldb_mux( .sel(trap_mux_out[0]), .a(c_rdata_b[7:0]), .b(c_rdata_b[15:8]), .f(ldb_mux_out));
mux2 #(.width(16)) mem_read_mux( .sel(ex_mem_ctrl_out.byte_access), .a(c_rdata_b), .b({8'b0,ldb_mux_out}), .f(mem_read_mux_out));
gencc mem_gencc (.in(c_rdata_b), .out(mem_cc));

mux2 #(.width(3)) gccmux ( .sel(ex_mem_ctrl_out.gccmux_sel), .a(ex_mem_alu_nzp_out), .b(mem_cc), .f(gccmux_out) );
register #(.width(3)) cc_reg  (.*, .load(ex_mem_ctrl_out.load_cc), .clear(0), .in(gccmux_out), .out(cc_out));

cccomp cccomp(.a(cc_out), .b(ex_mem_ir_out[11:9]), .br_enb(branch_taken));

jsr_adder jsr_adder (.offset11(ex_mem_ir_out[10:0]), .pc(ex_mem_pc_out), .out(jsr_adder_out));
mux2 #(.width(16)) jsrmux( .sel(ex_mem_ctrl_out.jsr_direct), .a(ex_mem_alu_out), .b(jsr_adder_out), .f(jsrmux_out) );



branch_prediction_unit branch_prediction_unit
(.*, .stall(stall_ex_mem), .if_taken(branch_taken), .from_source(pc_reg_out+2), .to_target(predict_addr), .take_branch(predict_take),
.source_pc(ex_mem_pc_out), .source_ir(ex_mem_ir_out), .target_pc(ex_mem_alu_out));




			  
//MEM↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑MEM↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑MEM


mem_wb_reg mem_wb_reg(.*,  .clear(clear_mem_wb), .load(!stall_mem_wb),
.pc_in(ex_mem_pc_out), .ir_in(ex_mem_ir_out), .mem_in(mem_read_mux_out), .alu_in(ex_mem_alu_out), .ctrl_in(ex_mem_ctrl_out),
.pc_out(mem_wb_pc_out), .ir_out(mem_wb_ir_out), .mem_out(mem_wb_mem_out), .alu_out(mem_wb_alu_out), .ctrl_out(mem_wb_ctrl_out)
);

//WB↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓WB↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓WB

//write-back content
decode_mux #(.width(16)) regfilemux( .sel_1(mem_wb_ctrl_out.regfilemux_sel), .sel_2((mem_wb_ir_out[15:12] == op_trap)||(mem_wb_ir_out[15:12] == op_jsr)), .sel_3(0), .sel_4(0), .sel_5(0), .sel_6(0), .sel_7(0),
              .in_0(mem_wb_alu_out), .in_1(mem_wb_mem_out), .in_2(mem_wb_pc_out), .in_3(0), .in_4(0), .in_5(0), .in_6(0), .in_7(0), 
				  .out(regfilemux_out));
//write-back register select
mux2 #(.width(3)) destReg_mux( .sel((mem_wb_ir_out[15:12] == op_trap)||(mem_wb_ir_out[15:12] == op_jsr)), .a(mem_wb_ir_out[11:9]), .b(7), .f(destReg_mux_out) );

wb_retain wb_retain(.*, .clear(0), .load(!stall_mem_wb && mem_wb_ctrl_out.load_regfile), .reg_sel(destReg_mux_out), .reg_in(regfilemux_out),
.reg_sel_0(wb_reg_sel_0), .reg_sel_1(wb_reg_sel_1),
.reg_out_0(wb_reg_out_0), .reg_out_1(wb_reg_out_1));



endmodule : cpu
