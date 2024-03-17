/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  parameter RD_NR = 20;
  parameter WR_NR = 20;

  int seed = 555;

  initial begin //timpul 0 al simularii se executa
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer*
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin - cod original
    repeat (WR_NR) begin //modificare 11.03.2024 
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin - cod original
    for (int i=0; i<=RD_NR; i++) begin //modificare 11.02.2024
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
      check_results;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0; //static - alocata o singura data la apelul functiei
    operand_a     <= $random(seed)%16;                 // between -15 and 15 ..random genereaza un nr pe 32 biti, vendor - producator tool -2G....+2G
    operand_b     <= $unsigned($random)%16;            // between 0 and 15 //converteste nr negative la pozitive 
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.result);
  endfunction: print_results

  function check_results;
  //calculam si aici rezultatul si comparam cu cel primit de la DUT
  //actual instr_word.result, declaram variabila locala exp_result
  //din instr lusm op a, op b, opcode si mai facem calculul o data
   //la final un if separat care trebuie sa faca comparatie intre rezultat comparat aici si rezultatul primit
  int expected_result;
  if (instruction_word.opc == ZERO) 
    expected_result = 0;
  else if (instruction_word.opc == PASSA)
    expected_result = instruction_word.op_a;
  else if (instruction_word.opc == PASSB)
    expected_result = instruction_word.op_b;
  else if (instruction_word.opc == ADD)
    expected_result = instruction_word.op_a + instruction_word.op_b;
  else if (instruction_word.opc == SUB)
    expected_result = instruction_word.op_a - instruction_word.op_b;
  else if (instruction_word.opc == MULT)
    expected_result = instruction_word.op_a * instruction_word.op_b;
  else if (instruction_word.opc == DIV) begin
    if(instruction_word.op_b== 0)
      expected_result = 0;
    else
      expected_result = instruction_word.op_a / instruction_word.op_b; 
  end
  else if (instruction_word.opc == MOD)
    expected_result = instruction_word.op_a % instruction_word.op_b;

  $display("Actual result = %0d\n", instruction_word.result);
  $display("Expected result = %0d\n", expected_result);
  if(expected_result == instruction_word.result)
     $display("The result is ok!");
  else
     $display("Error! There is a problem with the result!");

  endfunction: check_results

endmodule: instr_register_test
