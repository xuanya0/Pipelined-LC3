module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;


	 /* Port A */
    logic read_a;
    logic write_a;
    logic [1:0] wmask_a;
    logic [15:0] address_a;
    logic [15:0] wdata_a;
    logic resp_a;
    logic [15:0] rdata_a;

    /* Port B */
    logic read_b;
    logic write_b;
    logic [1:0] wmask_b;
    logic [15:0] address_b;
    logic [15:0] wdata_b;
    logic resp_b;
    logic [15:0] rdata_b;


cpu dut
(.*);


magic_memory_dp mmdp
(.*);



endmodule: mp3_tb