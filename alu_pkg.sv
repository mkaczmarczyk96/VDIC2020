`timescale 1ns/1ps
package alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	typedef enum bit[2:0] {and_op = 3'b000,
		or_op = 3'b001,
		add_op = 3'b100,
		sub_op = 3'b101} operation_t;

	typedef enum bit[2:0] {and_state = 3'b000,
		or_state = 3'b001,
		add_state = 3'b100,
		sub_state = 3'b101,
		rst_state = 3'b010} state_t;
	
	typedef struct packed
	{
		bit [31:0] result;
		bit [3:0] flags;
	} out_element_s;

	typedef struct packed
	{
		bit [31:0] B;
		bit [31:0] A;
		bit one;
		bit [2:0] op;
	} CRC_in_s;

	typedef struct packed
	{
		bit [31:0] C;
		bit zero;
		bit [3:0] flags;
	} CRC_out_s;
	
`include "sequence_item.svh"
 typedef uvm_sequencer #(sequence_item) sequencer;

`include "reset_sequence.svh"
`include "random_sequence.svh"
`include "min_max_sequence.svh"
`include "runall_sequence.svh"
`include "result_transaction.svh"
`include "coverage.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"
`include "alu_base_test.svh"
`include "full_test.svh"


endpackage : alu_pkg
