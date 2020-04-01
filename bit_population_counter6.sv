module bit_population_counter6 #(

parameter int WIDTH=20

)(
input logic clk_i,
input logic srst_i,
input logic [WIDTH-1:0] data_i,
input logic data_val_i,
output logic [$clog2(WIDTH):0] data_o,
output logic data_val_o
);

logic [WIDTH-1:0] width;

always_comb


begin
	width=0;
	for (int i=0; i<WIDTH; i++) 
	width=width+data_i[i];
		
end

always_ff @(posedge clk_i)

if (srst_i) data_val_o<=1'b0;
else if (data_val_i) 
	begin
	data_val_o<=1'b1;
	data_o<=width;
	end
else data_val_o<=1'b0;
endmodule

