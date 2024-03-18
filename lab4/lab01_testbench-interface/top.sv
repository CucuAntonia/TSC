/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
  timeunit 1ns/1ns;  //unitate de timp 1ns cu o rezolutie de 1ns

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk;
  logic test_clk;

  // interconnecting signals
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  operand_result result;
  instruction_t  instruction_word;   //t - template
  

  // instantiate testbench and connect ports
  instr_register_test test (
    .clk(test_clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .result(result),
    .instruction_word(instruction_word)
    
   );

  // clock oscillators
  initial begin   //se executa la momentul 0, timp de simulare 0...daca era fara begin putea sa fie o singura instr
    clk <= 0;
    forever #5  clk = ~clk; //asteapta 5 unitati de timp (timeunit mai sus, asteapta 5ns)
  end //factor de umplere: parier pozitiv/perioada x 100% = 5/10 x 100% = 50%
   

  initial begin //initial begin se executa paralel
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between 
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1; //perioada e 10ns, factor umplere = 80%, semnalele sunt defazate 
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
