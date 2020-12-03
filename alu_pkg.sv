`timescale 1ns/1ps


package alu_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"


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

	typedef struct packed{
		bit [31:0] A;
		bit [31:0] B;
		operation_t op;
		Current_state_t Current_state;
	} command_s;

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
		
		bit [2:0] op;} CRC_in_t;
	
	
	typedef struct packed
	{
		bit [31:0] C;
		
		bit zero;
		
		bit [3:0] flags;} CRC_out_t;

`include "coverage.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "base_tester.svh"
`include "random_tester.svh"
`include "min_max_tester.svh"   
`include "result_monitor.svh"
`include "env.svh"
`include "add_random_test.svh"
`include "add_min_max_test.svh"

endpackage : alu_pkg
