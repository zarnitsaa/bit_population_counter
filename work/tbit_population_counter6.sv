`timescale 10ns/1ns //?? ????? ??? ?????????????? ?????????

module testbench_bit_population_counter;

parameter int CLK=20; //period clk
parameter int WIDTH=20; //??????????? ??????
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
.clk_i (clk_i_ext),
.srst_i (srst_i_ext),
.data_i (data_i_ext),
.data_val_i (data_val_i_ext),
.data_o (data_o_ext),
.data_val_o (data_val_o_ext)
);

initial//??????? ???????? ???????
begin
forever begin
#(CLK/2);
clk_i_ext=~clk_i_ext;
end
end


initial//validity of input changes with period VAL
begin
	repeat (VAL) 
	begin
	@(posedge clk_i_ext);
	data_val_i_ext=~data_val_i_ext;
	end
end

task sync_rst();//?????????? ?????
@(posedge clk_i_ext);
srst_i_ext<=1'b1;
@(posedge clk_i_ext);
srst_i_ext<=1'b0;
endtask;

//logic [WIDTH:0] rand_queue [$:CNT];//создание и заполнение очереди из CNT элементов
//rand_queue=new;
//foreach(rand_queue [i])     =$urandom);//generates a 32-bit unsigned number
//int rand_number;
//task filling_queue (rand_queue);
//repeat (CNT)
//begin
//	@(posedge clk_i_ext)
//	begin
//	rand_number=$urandom;
//	rand_queue.push_front(rand_number);
//	end
//end
//endtask
//rand [WIDTH:0] rand_queue [$:CNT];//???????? ? ?????????? ??????? ?? CNT ?????????
logic [WIDTH:0] rand_queue [$:CNT];//                                          
initial                                                                        
  begin                                                                        
    foreach (rand_queue [i])                                                   
      rand_queue[i] = $urandom;//generates a 32-bit unsigned number            
  end

task input_stumulus (input rand_queue);//????????? ??????? ? ?????????? ??????? ???????????
	for (int j=0; j<CNT; j++)
	begin
	@(posedge clk_i_ext)
	data_val_i_ext<=1'b1;
	data_i_ext[j]<=rand_queue[j];
	end
endtask

logic [WIDTH:0] output_queue [$:CNT];

task output_stumulus (input data_o_ext, input data_val_i_ext, output output_queue);//?????? ?? data_val_o_ext ? ?????????? ???????? ?????? ? ???????
	for (int i=0; i<=CNT; i++)
		begin
		wait(data_val_i_ext);
		@(posedge clk_i_ext)
			begin
			data_val_o_ext<=1'b1;
			output_queue[i]<=data_o_ext;
			end
		end
endtask

task check (input rand_queue, input output_queue);
	@(posedge clk_i_ext)
		for (int k=0; k<=CNT; k++)
			begin
			assert ($countbits(rand_queue[k],'1)==output_queue[k]) 
			$dispay ("OK"); else $error ("It's gone wrong");
			end 
endtask



initial
begin
filling_queue (rand_queue);
@(posedge clk_i_ext)
fork
	begin
	input_stumulus (rand_queue);
	output_stumulus (data_o_ext, data_val_i_ext,output_queue);
	end
join
check (rand_queue, output_queue);
sync_rst();//do I need to put it before fork-join statement?

$stop();//do I need this line?
end

endmodule

