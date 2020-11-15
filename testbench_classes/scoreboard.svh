class scoreboard;

	virtual alu_bfm bfm;
	
	sin_queue_t sin_queue [$];
	sin_queue_t sin_queue_element;
	
	data_in_t scoreboard_sin;
	
	CRC_in_t CRC_in_data;
	
	bit [3:0] expected_CRC_in;
	bit [2:0] expected_CRC_out;
	
	bit [5:0] expected_error_flags;
	bit [3:0] expected_flags;
	
	bit expected_parity;
	
	bit [98:0] scoreboard_din;
	bit [10:0] scoreboard_sin_byte;
	
	bit carry,overflow,zero,negative;
	
	bit [3:0] A_frame_counter;
	bit [3:0] B_frame_counter;

	bit [10:0] frame_out;
	
	bit [3:0] out_data_frame_counter;
	
	bit [5*11-1:0] deserialize_sout_data;
	bit deserialize_sout_done;
	
	sin_queue_t out_element;
	sin_queue_t data_to_compare;
	
	bit [5*11-1:0] scoreboard_data_out;
	bit [3:0] collected_data_counter;
	
//------------------------------------------------------------------------------
// "New" auxiliary function
//------------------------------------------------------------------------------

	function new (virtual alu_bfm b);
		bfm = b;
	endfunction : new


//------------------------------------------------------------------------------
// calculate CRC out function
//------------------------------------------------------------------------------

	protected function [2:0] calculate_CRC_out;
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
// Calculate expected data task
//------------------------------------------------------------------------------

	task generate_expected_data();
		forever begin
			@(posedge bfm.deserialize_sin_done);
			scoreboard_din = bfm.sin_data;
			A_frame_counter = 0;
			B_frame_counter = 0;
			{carry,overflow,negative,zero} = 4'b0000;
			begin: calculate_expected_data
				repeat(4)begin //B
					scoreboard_sin_byte = scoreboard_din[98-:11];
					scoreboard_din <<= 11;
					if(scoreboard_sin_byte[10:9] == 2'b00 && scoreboard_sin_byte[0] == 1'b1)begin
						scoreboard_sin.B <<= 8;
						scoreboard_sin.B[7:0] = scoreboard_sin_byte[8:1];
					end
					else begin
						expected_error_flags = 6'b100100;//DATA ERROR FLAGS
						disable calculate_expected_data;
					end
					B_frame_counter++;
				end
				repeat(4)begin //A
					scoreboard_sin_byte = scoreboard_din[98-:11];
					scoreboard_din <<= 11;
					if(scoreboard_sin_byte[10:9] == 2'b00 && scoreboard_sin_byte[0] == 1'b1)begin
						scoreboard_sin.A <<= 8;
						scoreboard_sin.A[7:0] = scoreboard_sin_byte[8:1];
					end
					else begin
						expected_error_flags = 6'b100100;//DATA ERROR FLAGS
						disable calculate_expected_data;
					end
					A_frame_counter++;
				end

				scoreboard_sin_byte = scoreboard_din[98-:11];
				scoreboard_din <<= 11;
				
				if(scoreboard_sin_byte[10:8] == 3'b010 && scoreboard_sin_byte[0] == 1'b1)begin
					scoreboard_sin.op = scoreboard_sin_byte[7-:3];
					scoreboard_sin.CRC = scoreboard_sin_byte[4-:4];
				end
				else begin
					expected_error_flags = 6'b100100;//DATA ERROR FLAGS
					disable calculate_expected_data;
				end

				CRC_in_data.B   = scoreboard_sin.B;
				CRC_in_data.A   = scoreboard_sin.A;
				CRC_in_data.op  = scoreboard_sin.op;
				CRC_in_data.one = 1'b1;
				expected_CRC_in = bfm.generate_CRC(CRC_in_data);
				
				if(expected_CRC_in != scoreboard_sin.CRC)begin
					expected_error_flags = 6'b010010;//CRC ERROR FLAGS
					disable calculate_expected_data;
				end
			end: calculate_expected_data

			sin_queue_element.B_width = B_frame_counter;;
			sin_queue_element.B = scoreboard_sin.B;
			sin_queue_element.A_width = A_frame_counter;
			sin_queue_element.A = scoreboard_sin.A;
			sin_queue_element.op = scoreboard_sin.op;

			if(expected_error_flags == 6'd0)begin
				case(scoreboard_sin.op)
					ADD: begin
						{carry,sin_queue_element.expected_data} = scoreboard_sin.A+scoreboard_sin.B;
						overflow = (scoreboard_sin.A[31] & scoreboard_sin.B[31] & ~sin_queue_element.expected_data[31])||
						(~scoreboard_sin.A[31] & ~scoreboard_sin.B[31] & sin_queue_element.expected_data[31]);
					end
					SUB: begin
						{carry,sin_queue_element.expected_data} = scoreboard_sin.B-scoreboard_sin.A;
						overflow = (scoreboard_sin.B[31] & ~scoreboard_sin.A[31] & ~sin_queue_element.expected_data[31])||
						(~scoreboard_sin.B[31] & scoreboard_sin.A[31] & sin_queue_element.expected_data[31]);
					end
					AND: begin
						sin_queue_element.expected_data = scoreboard_sin.A&scoreboard_sin.B;
					end
					OR: begin
						sin_queue_element.expected_data = scoreboard_sin.A|scoreboard_sin.B;
					end
					default: expected_error_flags = 6'b001001; //OPERATION CODE ERROR
				endcase
				zero = ~(|sin_queue_element.expected_data);
				negative = sin_queue_element.expected_data[31];
			end
			if(expected_error_flags == 6'd0)begin
				sin_queue_element.expected_width = 5;
				expected_flags = {carry,overflow,zero,negative};
				expected_CRC_out = calculate_CRC_out({sin_queue_element.expected_data,1'b0, expected_flags});
				sin_queue_element.expected_control_data = {1'b0,expected_flags,expected_CRC_out};
			end
			else begin
				sin_queue_element.expected_width = 1;
				expected_parity = 1'b1^(^expected_error_flags);
				sin_queue_element.expected_control_data = {1'b1,expected_error_flags,expected_parity};
			end

			sin_queue.push_front(sin_queue_element);
		end
	endtask : generate_expected_data


//------------------------------------------------------------------------------
// Deserialize sout task
//------------------------------------------------------------------------------

	task deserialize_sout();
		forever begin
			@(negedge bfm.sout);
			deserialize_sout_done = 0;

			fork: collect_byte_out
				begin
					repeat(11) begin
						@(posedge bfm.clk);
						frame_out <<= 1;
						frame_out[0] = bfm.sout;
					end
					disable collect_byte_out;
				end

				@(negedge bfm.rst_n) disable collect_byte_out;
			join

			deserialize_sout_data[(5-out_data_frame_counter)*11-1-:11] = frame_out;
			out_data_frame_counter++;

			if(!bfm.rst_n || out_data_frame_counter == 5 || frame_out[10:9] == 2'b01) begin
				out_data_frame_counter = 0;
				frame_out = 11'd0;
				if(bfm.rst_n)begin
					deserialize_sout_done = 1;
				end
			end
		end
	endtask


//------------------------------------------------------------------------------
// Delete element from queue when reset is active task
//------------------------------------------------------------------------------

	task delete_first_element();
		forever begin
			@(negedge bfm.rst_n);
			
			sin_queue.pop_front();
		end
	endtask

//------------------------------------------------------------------------------
// automated checker task
//------------------------------------------------------------------------------

	task scoreobard_checker();
		forever begin
			@(posedge deserialize_sout_done);
			scoreboard_data_out = deserialize_sout_data;
			collected_data_counter = 0;
			repeat(5)begin: parse_data;

				frame_out = scoreboard_data_out[54-:11];
				scoreboard_data_out <<= 11;
				collected_data_counter ++;
				if(frame_out[10:9]==2'b01 && frame_out[0]==1'b1)begin
					out_element.expected_control_data = frame_out[8:1];
					disable parse_data;
				end
				else if(frame_out[10:9]==2'b00 && frame_out[0]==1'b1)begin
					out_element.expected_data <<= 8;
					out_element.expected_data[7:0] = frame_out[8:1];
				end
			end: parse_data
			
			data_to_compare = sin_queue.pop_back();

			if(collected_data_counter == 1 && data_to_compare.expected_width == 1)begin
				if(data_to_compare.expected_control_data!= out_element.expected_control_data)begin
					bfm.error = 1;
				end
			end
			else if(collected_data_counter == 5 && data_to_compare.expected_width == 5)begin
				if(data_to_compare.expected_data != out_element.expected_data)begin
					bfm.error = 1;
				end
				else if(data_to_compare.expected_control_data != out_element.expected_control_data)begin
					bfm.error = 1;
				end
			end
			else begin
				bfm.error = 1;
			end
		end
	endtask




//------------------------------------------------------------------------------
//Execute
//------------------------------------------------------------------------------

	task execute();
		fork
			delete_first_element;
			deserialize_sout;
			generate_expected_data;
			scoreobard_checker;
		join
	endtask

endclass : scoreboard
