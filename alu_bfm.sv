interface alu_bfm;
	import alu_pkg::*;

	bit clk;
	bit sin;
	bit rst_n;
	wire sout;

	bit error;

	bit [5*11-1:0] scoreboard_data_out;
	bit [3:0] collected_data_counter;
	result_monitor result_monitor_h;

	bit [10:0] byte_in;
	bit [3:0] in_data_frame_counter;
	bit [98:0] deserialize_sin_data;
	bit deserialize_sin_done;

	bit [98:0] scoreboard_sin_data;
	bit carry,overflow,zero,negative;
	bit [10:0] byte_out;
	bit [3:0] out_data_frame_counter;
	bit [5*11-1:0] deserialize_sout_data;
	bit deserialize_sout_done;

	//------------------------------------------------------------------------------
	// Clock generator
	//------------------------------------------------------------------------------
	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end

	//------------------------------------------------------------------------------
	//sin deserialize
	//------------------------------------------------------------------------------

	always @(negedge sin or negedge rst_n) begin : deserialize_sin
		deserialize_sin_done       = 0;

		fork: collect_byte
			begin
				repeat(11) begin
					@(posedge clk);
					byte_in <<= 1;
					byte_in [0] = sin;
				end
				disable collect_byte;
			end

			wait(!rst_n) disable collect_byte;
			@(negedge rst_n) disable collect_byte;
		join

		deserialize_sin_data <<= 11;
		deserialize_sin_data[10:0] = byte_in;

		in_data_frame_counter++;

		if(!rst_n || in_data_frame_counter == 9 || byte_in[10:9] == 2'b01) begin
			in_data_frame_counter = 0;
			byte_in               = 11'd0;
			if(rst_n)begin
				deserialize_sin_done = 1; //trigger block using the deserialize_sin_data
			end
		end
	end : deserialize_sin

	task send_data;
		input bit [7:0] data_in;
		input bit data_command_select; // 0-data, 1-command
		bit [10:0] data_to_send;
		begin
			data_to_send = {1'b0,data_command_select,data_in,1'b1};
			repeat(11)begin
				@(negedge clk);
				sin = data_to_send[10];
				data_to_send <<= 1;
			end
		end
	endtask

	function [3:0] get_CRC_in;

		input bit [67:0] data;
		bit [67:0] d;
		bit [3:0] c;
		bit [3:0] newcrc;
		begin
			d          = data;
			c          = 0;

			newcrc[0]  = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
			newcrc[1]  = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
			newcrc[2]  = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
			newcrc[3]  = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
			get_CRC_in = newcrc;
		end
	endfunction

	function [2:0] get_CRC_out;
		input [36:0] data;
		reg [36:0] d;
		reg [2:0] c;
		reg [2:0] newcrc;
		begin
			d           = data;
			c           = 0;

			newcrc[0]   = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
			newcrc[1]   = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
			newcrc[2]   = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
			get_CRC_out = newcrc;
		end
	endfunction


	task perform_op;
		input bit [31:0] A;
		input bit [31:0] B;
		input state_t state;
		operation_t op;
		integer i;
		bit [3:0] CRC;

		begin
			if(state != rst_state)begin
				case(state)
					add_state: op = add_op;
					or_state: op = or_op;
					sub_state: op = sub_op;
					and_state: op = and_op;
				endcase

				for(i=0;i<4;i++)begin
					send_data(B[(4-i)*8-1-:8],0);
				end
				for(i=0;i<4;i++)begin
					send_data(A[(4-i)*8-1-:8],0);
				end
				CRC   = get_CRC_in({B,A,1'b1,op});
				send_data({1'b0,op,CRC},1);
			end
			else begin
				rst_n = 0;
				sin   = 1;
				repeat(2) @(negedge clk);
				rst_n = 1;
			end
		end
	endtask


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

		deserialize_sout_data[(5-out_data_frame_counter)*11-1-:11] = byte_out;

		out_data_frame_counter++;

		if(!rst_n || out_data_frame_counter == 5 || byte_out[10:9] == 2'b01) begin
			out_data_frame_counter = 0;
			byte_out               = 11'd0;
			if(rst_n)begin
				deserialize_sout_done = 1;
			end
		end
	end


	task process_deserial_sin;
		input [98:0] deserialize_sin_data;
		output [31:0] A,B;
		output operation_t op;
		output state_t state;
		operation_t opi;
		begin
			B  = {deserialize_sin_data[98-2-:8],deserialize_sin_data[98-11-2-:8],deserialize_sin_data[98-22-2-:8],deserialize_sin_data[98-33-2-:8]};
			A  = {deserialize_sin_data[98-44-2-:8],deserialize_sin_data[98-55-2-:8],deserialize_sin_data[98-66-2-:8],deserialize_sin_data[98-77-2-:8]};
			$cast(opi,{deserialize_sin_data[98-88-3-:3]});
			op = opi;
			case(op)
				and_op: state = and_state;
				add_op: state = add_state;
				sub_op: state = sub_state;
				or_op:  state  = or_state;
			endcase
		end
	endtask

	bit [31:0] A2mon,B2mon;
	operation_t op2mon;
	state_t state2mon;
	
	always @(posedge deserialize_sin_done or negedge rst_n) begin
		if(rst_n)begin
			process_deserial_sin(deserialize_sin_data,A2mon,B2mon,op2mon,state2mon);
		end
		else begin
			op2mon = add_op;
			state2mon = rst_state;
			A2mon = 0;
			B2mon = 0;
		end
		command_monitor_h.write_to_monitor(A2mon, B2mon, op2mon, state2mon);
	end

	out_element_s out_data;

	always @(posedge deserialize_sout_done) begin
		out_data.result = {deserialize_sout_data[54-2-:8],deserialize_sout_data[54-11-2-:8],deserialize_sout_data[54-22-2-:8],deserialize_sout_data[54-33-2-:8]};
		out_data.flags  = {deserialize_sout_data[54-44-3-:4]};

		result_monitor_h.write_to_monitor(out_data);
	end

	command_monitor command_monitor_h;

	final begin
		if(error) $display("==============================TEST FAILED==============================");
		else $display("==============================TEST PASSED==============================");
	end

endinterface
