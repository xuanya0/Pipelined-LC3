import lc3b_types::*;
module SR_array #(parameter width = 1)
(
    input clk,
    input enable,
    input set, reset,
    input [2:0] index,
    output logic [width-1:0] dataout
);
logic [width-1:0] data [7:0];
/* Initialize array */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 1'b0;
    end
end
always_ff @(posedge clk)
begin
	if (enable && reset)
		data[index] = 0;
	if (enable && set  )
		data[index] = 1;
	
end
assign dataout = data[index];
endmodule : SR_array