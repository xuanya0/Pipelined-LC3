/*

 * Dual-port magic memory

 *

 * Usage note: Avoid writing to the same address on both ports simultaneously.

 */



module magic_memory_dp

(

    input clk,



    /* Port A */

    input read_a,

    input write_a,

    input [1:0] wmask_a,

    input [15:0] address_a,

    input [15:0] wdata_a,

    output logic resp_a,

    output logic [15:0] rdata_a,



    /* Port B */

    input read_b,

    input write_b,

    input [1:0] wmask_b,

    input [15:0] address_b,

    input [15:0] wdata_b,

    output logic resp_b,

    output logic [15:0] rdata_b

);



timeunit 1ns;

timeprecision 1ns;

parameter DELAY_MEM_A = 20;
parameter DELAY_MEM_B = 30;

enum int unsigned {
    idle_a,
    busy_a,
    respond_a
} state_a, next_state_a;

enum int unsigned {
    idle_b,
    busy_b,
    respond_b
} state_b, next_state_b;
logic ready_a;
logic ready_b;

logic [7:0] mem [0:2**($bits(address_a))-1];

logic [15:0] internal_address_a;

logic [15:0] internal_address_b;



/* Initialize memory contents from memory.lst file */

initial

begin

    $readmemh("memory.lst", mem);
	state_a = idle_a;
	state_b = idle_b;

end



/* Calculate internal address */

assign internal_address_a = {address_a[15:1], 1'b0};

assign internal_address_b = {address_b[15:1], 1'b0};



/* Read */

always_comb

begin : mem_read_a

    rdata_a = {mem[internal_address_a+1], mem[internal_address_a]};

    rdata_b = {mem[internal_address_b+1], mem[internal_address_b]};

end : mem_read_a



/* Port A write */

always @(posedge clk)

begin : mem_write_a

    if (write_a)

    begin

        if (wmask_a[1])

        begin

            mem[internal_address_a+1] = wdata_a[15:8];

        end



        if (wmask_a[0])

        begin

            mem[internal_address_a] = wdata_a[7:0];

        end

    end

end : mem_write_a



/* Port B write */

always @(posedge clk)

begin : mem_write_b

    if (write_b)

    begin

        if (wmask_b[1])

        begin

            mem[internal_address_b+1] = wdata_b[15:8];

        end



        if (wmask_b[0])

        begin

            mem[internal_address_b] = wdata_b[7:0];

        end

    end

end : mem_write_b



/* Magic memory responds (after 3 cycles)immediately */
/*always @ (posedge clk)
begin
//resp_a = 1'b0;
//resp_b = 1'b0;
next_state_a = state_a ;
next_state_b = state_b ;
case(state_a)
	idle_a: begin
		if (read_a | write_a) begin
			next_state_a = busy_a;
			ready_a <= #DELAY_MEM_A 1;
		end
	end
	busy_a: begin
		if (ready_a == 1) begin
		//resp_a = 1;
		next_state_a = respond_a;
	end
	end	
	respond_a: begin
		ready_a <= 0;
		next_state_a = idle_a;
	end
endcase
case(state_b)
	idle_b: begin
		if (read_b | write_b) begin
			next_state_b = busy_b;
			ready_b <= #DELAY_MEM_B 1;
		end
	end
	busy_b: begin
		if (ready_b == 1) begin
		//resp_b = 1;
		next_state_b = respond_b;
	end
	end	
	respond_b: begin
		ready_b <= 0;
		next_state_b = idle_b;
	end
endcase
end
always_ff @ (posedge clk)
begin
	state_a <= next_state_a;
	state_b <= next_state_b;
end
always_comb
begin
resp_a = 1'b0;
resp_b = 1'b0;
case(state_a)
idle_a:;
busy_a:
begin
if (ready_a) begin
 resp_a = 1'b1;
end
end
respond_a:;
endcase
case(state_b)
idle_b:;
busy_b:
begin
if (ready_b) begin
 resp_b = 1'b1;
end
end
respond_b:;
endcase
end*/

assign resp_a = read_a | write_a;

assign resp_b = read_b | write_b;



endmodule : magic_memory_dp