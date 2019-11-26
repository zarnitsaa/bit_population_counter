timescale 1ps/1ps; //

module testbench_bit_population_counter;

parameter int CLK=20; //period clk
parameter int WIDTH=20; //
parameter int CNT=20; //how many numbers in queque
parameter int VAL=30; //period of validity of input signal

logic clk_i_ext;
logic srst_i_ext;
logic data_i_ext;
logic data_val_i_ext;
logic data_o_ext;
logic data_val_o_ext;

//instantiate module inside testbench

bit_population_counter #(
) bit_population_inst (
.clk_i (clk_i_ext)
.srst_i (srst_i_ext),
.data_i (data_i_ext),
.data_val_i (data_val_i_ext),
.data_o (data_o_ext),
.data_val_o (data_val_o_ext)
);

initial//
begin
forever begin
#(CLK/2);
clk_i_ext=~clk_i_ext;
end
end

task sync_rst();//
@(posedge clk_i_ext);
srst_i_ext<=1'b1;
@(posedge clk_i_ext);
srst_i_ext<=1'b0;
endtask;

logic [WIDTH:0] rand_queue [$:CNT];//
rand_queue=new;
foreach (rand_queue [i]=$urandom);//generates a 32-bit unsigned number

task input_stumulus (input rand_queue);//
	begin
			for (i=0; i<=CNT; i++)
			@(posedge clk_i_ext)
			data_val_i<=1'b1;
			data_i_ext[i]<=rand_queue[i]
 			end
	end
endtask

logic [WIDTH:0] output_queue [$:CNT];

task output_stumulus (input data_o_ext, input data_val_o_ext, output output_queue);//������ �� data_val_o_ext � ���������� �������� ������ � �������
	begin
			begin
			for (i=0; i<=CNT; i++)
			@(posedge clk_i_ext)
			data_val_o_ext<=1'b1;
			output_queue[i]<=data_o_ext;
			end 
	end
endtask

task check (input rand_queue, input output_queue);
	begin
	@(posedge clk_i_ext)
			begin
			for (i=0; i<=CNT; i++)
				begin
				assert ($countbits(rand_queue[i],'1)==output_queue[i] 
				$dispay ("OK") else $error ("It's gone wrong");
				end 
			end 
	
	end
endtask



initial
begin
@(posedge clk_i_ext)
fork
	begin
	input_stumulus (rand_queue);
	output_stumulus (data_o_ext, data_val_o_ext,output_queue);
	end
join
check (rand_queue, output_queue)
sync_rst();



$stop();
end
endmodule
