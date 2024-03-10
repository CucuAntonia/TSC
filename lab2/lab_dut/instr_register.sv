/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word,
 output operand_result result
);
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register //letch-comuta pe palier, ff - comuta pe front....    , = sau
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros //sintaxa de a initializa o structura in sv ' = indiferent de nr de biti
    end
    else if (load_en) begin //punem case pt opcode si stocam intr o variabila noua rezultat (rez) pe care o bagam si in structura //instr word de read pointer - trebe sa apara rezultatul
      case(opcode) 
          ZERO: result = 0;
          PASSA: result = operand_a;
          PASSB: result = operand_b;
          ADD: result = operand_a + operand_b;
          SUB: result = operand_a - operand_b;
          MULT: result = operand_a * operand_b;
          DIV: result = operand_a / operand_b;
          MOD: result = operand_a % operand_b;
      endcase
          iw_reg[write_pointer] = '{opcode,operand_a,operand_b,result};   //starea default la logic e x - don't care
    end
    //sv truncheaza in caz de overflow...de exemplu valorea 63 -> 31 (truncheaza)

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
