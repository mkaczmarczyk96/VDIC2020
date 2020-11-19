interface alu_bfm;
	import alu_pkg::*;
	
	bit clk;
	bit sin;
	bit rst_n;
	wire sout;
	
	bit error;

	bit [10:0] data_in;
	
	bit [3:0] frame_count;
	
	bit [98:0] sin_data;
	bit deserialize_sin_done;
	
//------------------------------------------------------------------------------
// Generate CRC function
//------------------------------------------------------------------------------
	
	function [3:0] generate_CRC;

		input bit [67:0] data;
		
		bit [67:0] d;
		bit [3:0] c;
		
		bit [3:0] newcrc;
		
		begin
			
			d = data;
			c = 0;

			newcrc[0]  = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
			newcrc[1]  = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
			newcrc[2]  = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
			newcrc[3]  = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
			
			generate_CRC = newcrc;
			
		end
	endfunction


	//------------------------------------------------------------------------------
	//Transceive/Decode Serial Data - deserialize data
	//------------------------------------------------------------------------------


	always @(negedge sin or negedge rst_n) begin : deserialize_data_in
		deserialize_sin_done = 0;

		fork: decode_data_frame
			begin
				repeat(11) begin
					@(posedge clk);
					data_in <<= 1;
					data_in [0] = sin;
				end
				disable decode_data_frame;
			end

			wait(!rst_n) disable decode_data_frame;
			@(negedge rst_n) disable decode_data_frame;
		join

		sin_data <<= 11;
		sin_data[10:0] = data_in;
		frame_count++;

		if(!rst_n || frame_count == 9 || data_in[10:9] == 2'b01) begin
			frame_count = 0;
			data_in = 11'd0;
			if(rst_n)begin
				deserialize_sin_done = 1;
			end
		end
	end : deserialize_data_in
	
	
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------
	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frequency
			#10;
			clk = ~clk;
		end : clk_frequency
	end : clk_gen
	
	
//------------------------------------------------------------------------------
// Transceive data byte + control bits task
//------------------------------------------------------------------------------
	task transceive_data;
		input bit [7:0] data;
		input bit data_command_control_bit; // 0-data transmission enabled, 1-command transmission enabled
		
		bit [10:0] data_to_transceive;
		begin
			data_to_transceive = {1'b0,data_command_control_bit,data,1'b1};
			repeat(11)begin
				@(negedge clk);
				sin = data_to_transceive[10];
				data_to_transceive <<= 1;
			end
		end
	endtask
	
	
//------------------------------------------------------------------------------
// Transceive data byte + control bits task
//------------------------------------------------------------------------------

	task perform_operation;
		
		input bit [31:0] A;
		input bit [31:0] B;
		
		input operation_t op;
		
		integer i;
		
		bit [3:0] CRC;

		begin
			for(i=0;i<4;i++)begin
				transceive_data(A[(4-i)*8-1-:8],0);
			end	
			for(i=0;i<4;i++)begin
				transceive_data(B[(4-i)*8-1-:8],0);
			end		
			CRC = generate_CRC({A,B,1'b1,op});
			transceive_data({1'b0,op,CRC},1);
		end
	endtask
	
endinterface
