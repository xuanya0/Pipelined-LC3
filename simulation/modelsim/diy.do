transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/register.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/mux2.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/lc3b_types.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/cccomp.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/br_adder.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/opcode_decoder.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/adj.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/regfile.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/mem_wb_reg.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/if_id_reg.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/id_ex_reg.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/gencc.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/ex_mem_reg.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/alu.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/cpu.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/mp3.sv}

vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/mp3_tb.sv}
vlog -sv -work work +incdir+C:/Users/phill_000/Google\ Drive/ece411/mp3 {C:/Users/phill_000/Google Drive/ece411/mp3/magic_memory_dp.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  mp3_tb

add wave *
add wave -position insertpoint  \
sim:/mp3_tb/dut/cpu/regfile/data \
sim:/mp3_tb/dut/cpu/pc_reg/out \
sim:/mp3_tb/dut/cpu/mem_wb_reg/pc_out \
sim:/mp3_tb/dut/cpu/mem_wb_reg/operation \
sim:/mp3_tb/clk


view structure
view signals
run 1500 ns
