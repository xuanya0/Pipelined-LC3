import lc3b_types::*;

module mem_indirect
(
    input clk,
	 input stldi,
    //cpu
    input c_read_b,
    input c_write_b,
    input [1:0] c_wmask_b,
    input [15:0] c_address_b,
    input [15:0] c_wdata_b,
    output logic c_resp_b,
    output logic [15:0] c_rdata_b,
	 
	 
	 //physical
    output logic p_read_b,
    output logic p_write_b,
    output logic [1:0] p_wmask_b,
    output logic [15:0] p_address_b,
    output logic [15:0] p_wdata_b,
    input p_resp_b,
    input[15:0] p_rdata_b
);

logic indir_state;
initial indir_state = 0;

logic [15:0] indir_addr;

//state action
always_comb
begin
//default action
	//phy <- cpu
	p_read_b = c_read_b;
	p_write_b = c_write_b;
	p_wmask_b = c_wmask_b;
	p_address_b = c_address_b;
	p_wdata_b = c_wdata_b;
	//cpu <- phy
	c_resp_b = p_resp_b;
	c_rdata_b = p_rdata_b;
	
	//indirect init stage
	if (stldi && ~indir_state)
	begin
		//always read the address
		p_read_b = 1;
		p_write_b = 0;
		c_resp_b = 0;
	end
	
	//indirect second stage
	if (stldi && indir_state)
	begin
		p_address_b = indir_addr;
	end
	
end

//load intermediate address
always_ff @(posedge clk)
begin
	//first stage stldi
	if (p_resp_b && stldi && ~indir_state)
		indir_addr = p_rdata_b;
end


//state transition
always_ff @(posedge clk)
begin
	if (~indir_state && p_resp_b && stldi)
		indir_state = 1;
	else	
	if ( indir_state && p_resp_b)
		indir_state = 0;
end



endmodule : mem_indirect