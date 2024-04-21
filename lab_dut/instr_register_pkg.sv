/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] { //se folosesc 4 biti ca sa fie lasat loc de adaugat noi opcode-uri
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD,
    POW
  } opcode_t;

  typedef logic signed [31:0] operand_t;
  typedef logic signed [63:0] operand_result;
  
  typedef logic [4:0] address_t;
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    operand_result result;
  } instruction_t; //68 biti (132 biti folsind si operand_result)

endpackage: instr_register_pkg
