package lc3b_types;

typedef logic [15:0] lc3b_word;
typedef logic  [7:0] lc3b_byte;

typedef logic  [8:0] lc3b_offset9;
typedef logic  [5:0] lc3b_offset6;

typedef logic  [2:0] lc3b_reg;
typedef logic  [2:0] lc3b_nzp;
typedef logic  [1:0] lc3b_mem_wmask;



typedef enum bit [3:0] {
    op_add  = 4'b0001,
    op_and  = 4'b0101,
    op_br   = 4'b0000,
    op_jmp  = 4'b1100,   /* also RET */
    op_jsr  = 4'b0100,   /* also JSRR */
    op_ldb  = 4'b0010,
    op_ldi  = 4'b1010,
    op_ldr  = 4'b0110,
    op_lea  = 4'b1110,
    op_not  = 4'b1001,
    op_rti  = 4'b1000,
    op_shf  = 4'b1101,
    op_stb  = 4'b0011,
    op_sti  = 4'b1011,
    op_str  = 4'b0111,
    op_trap = 4'b1111
} lc3b_opcode;

typedef enum bit [3:0] {
    alu_add,
    alu_and,
    alu_not,
    alu_pass,
    alu_sll,
    alu_srl,
    alu_sra
} lc3b_aluop;


typedef logic  [30-1:0] ctrl_signal_length;
typedef struct packed
{
	logic load_pc;
	logic load_ir;
	logic load_regfile;
	lc3b_aluop aluop;
	logic gccmux_sel;
	logic mem_read;
	logic mem_write;
	lc3b_mem_wmask mem_byte_enable;
	logic pcmux_sel;
	logic storemux_sel;
	logic alumux_sel;
	logic regfilemux_sel;
	logic load_cc;
	logic pcsr1mux_sel;
	logic imm5mux_sel;
	logic leamux_sel;
	logic offset6mux_sel;
	logic mdr_to_mar;
	logic jsr_sel;
	logic trap_sel;
	logic trapmux_sel;
	logic stb_high_byte_sel;
	logic jsr_direct;
	logic imm4mux_sel;
	logic byte_access;
	logic mem_indirect;
} ctrl_struct;

endpackage : lc3b_types
