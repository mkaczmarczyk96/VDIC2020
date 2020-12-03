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

	bit [10:0] byte_out;
	bit [3:0] out_data_frame_counter;
	bit [54:0] sout_data;
	bit deserialize_sout_done;

	result_monitor result_monitor_h;
	command_monitor command_monitor_h;

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
// Generate CRC out function
//------------------------------------------------------------------------------

	function [2:0] calculate_CRC_out;
		input [36:0] data;
		reg [36:0] d;
		reg [2:0] c;
		reg [2:0] newcrc;
		begin
			d = data;
			c = 0;

			newcrc[0]   = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
			newcrc[1]   = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
			newcrc[2]   = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
			calculate_CRC_out = newcrc;
		end
	endfunction

//------------------------------------------------------------------------------
//Transceive/Decode Serial Data - deserialize data in
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
//Transceive/Decode Serial Data - deserialize data in
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//Transceive/Decode Serial Data - deserialize data out
//------------------------------------------------------------------------------

	always @(negedge sout) begin
		deserialize_sout_done = 0;

		fork: collect_byte_out
			begin
				repeat(11) begin
					@(posedge clk);
					byte_out <<= 1;
					byte_out[0] = sout;
				end
				disable collect_byte_out;
			end

			@(negedge rst_n) disable collect_byte_out;
		join

		sout_data[(5-out_data_frame_counter)*11-1-:11] = byte_out;
		out_data_frame_counter++;

		if(!rst_n || out_data_frame_counter == 5 || byte_out[10:9] == 2'b01) begin
			out_data_frame_counter = 0;
			byte_out = 11'd0;
			if(rst_n)begin
				deserialize_sout_done = 1;
			end
		end
	end

//------------------------------------------------------------------------------
//Transceive/Decode Serial Data - deserialize data out
//------------------------------------------------------------------------------
	
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

//------------------------------------------------------------------------------
// Perform operation
//------------------------------------------------------------------------------

	task perform_operation;
		input bit [31:0] A;
		input bit [31:0] B;

		input Current_state_t state;

		operation_t op;
		integer i;

		bit [3:0] CRC;

		begin
			if(state != RST_s)begin
				case(state)
					ADD_s: op = ADD;
					SUB_s: op = SUB;
					AND_s: op = AND;
					OR_s: op = OR;
					default: op = ADD;
				endcase
				
				for(i=0;i<4;i++)begin
					transceive_data(A[(4-i)*8-1-:8],0);
				end	
				for(i=0;i<4;i++)begin
					transceive_data(B[(4-i)*8-1-:8],0);
				end		
				CRC = generate_CRC({A,B,1'b1,op});
				transceive_data({1'b0,op,CRC},1);
				end
			else begin
				rst_n = 0;
				sin = 1;
				repeat(2) @(negedge clk);
				rst_n = 1;
			end
		end
	endtask : perform_operation

//------------------------------------------------------------------------------
// Perform operation
//------------------------------------------------------------------------------


	function command_s deserialize_sin_process_data;
		input [98:0] sin_data;
		command_s input_data;
		operation_t o;
		begin
			input_data.B = {sin_data[96-:8],sin_data[85-:8],sin_data[74-:8],sin_data[63-:8]};
			input_data.A = {sin_data[52-:8],sin_data[41-:8],sin_data[30-:8],sin_data[19-:8]};

			$cast(o,{sin_data[7-:3]});

			input_data.op = o;
			case(input_data.op)
				AND: input_data.Current_state = AND_s;
				ADD: input_data.Current_state = ADD_s;
				SUB: input_data.Current_state = SUB_s;
				OR: input_data.Current_state = OR_s;
			endcase
			return input_data;
		end
	endfunction 

	command_s command_monitor_data_in;
	
	always @(posedge deserialize_sin_done or negedge rst_n) begin
		if(rst_n)begin
			command_monitor_data_in = deserialize_sin_process_data(sin_data);
			command_monitor_h.write_to_monitor(command_monitor_data_in);
		end
		else begin
			command_monitor_data_in.Current_state = RST_s;
			command_monitor_h.write_to_monitor(command_monitor_data_in);
		end
	end


	out_element_s data_out;
	
	always @(posedge deserialize_sout_done) begin
		data_out.result = {sout_data[52-:8],sout_data[41-:8],sout_data[30-:8],sout_data[19-:8]};
		data_out.flags = {sout_data[7-:4]};
			
		result_monitor_h.write_to_monitor(data_out);
	end
	
	final begin
		if(error) $error("==============================TEST FAILED==============================");
		else $display("==============================TEST PASSED==============================");
	end

endinterface










