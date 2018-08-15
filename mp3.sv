import lc3b_types::*;

module mp3
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

cpu cpu(.*);

endmodule : mp3
