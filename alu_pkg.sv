`timescale 1ns/1ps


package alu_pkg;



	typedef enum bit[2:0] {
		AND = 3'b000,
		OR  = 3'b001,
		ADD = 3'b100,
		SUB = 3'b101} operation_t;
	

	typedef enum bit[2:0] {
		AND_s = 3'b000,
		OR_s  = 3'b001,
		ADD_s = 3'b100,
		SUB_s = 3'b101,
		RST_s = 3'b010} Current_state_t;
	
	
	typedef struct packed
	{
		bit [31:0] A;
		bit [3:0] A_width;
		
		bit [31:0] B;
		bit [3:0] B_width;
		
		bit [2:0] op;
		
		bit [2:0] expected_width;
		bit [31:0] expected_data;
		bit [7:0] expected_control_data;} sin_queue_t;
	

	typedef struct packed
	{
		bit [31:0] B;
		bit [31:0] A;
		
		bit zero;
		
		bit [2:0] op;
		
		bit [3:0] CRC;} data_in_t;
	

	typedef struct packed
	{
		bit [31:0] B;
		bit [31:0] A;
		
		bit one;
		
		bit [2:0] op;} CRC_in_t;
	
	
	typedef struct packed
	{
		bit [31:0] C;
		
		bit zero;
		
		bit [3:0] flags;} CRC_out_t;
	
	
`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "tb.svh"

endpackage : alu_pkg
