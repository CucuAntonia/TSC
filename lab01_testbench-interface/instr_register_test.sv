/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

//caracteristii functionale:
// preia a, b, wp, opcode 
// calculeaza un rez in functie de ele
// stocheaza a, b, opcode, result
// returneaza valorile stocate prin RDp
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
  parameter RD_NR = 10; //mecanismul de overflow (write e pe 5 biti, cand ajungem la o valoare > 31, atunci ajungem la 32 = 100000 si se iau ultimii 5 biti = 00000 = 0)
  parameter WR_NR = 10; //pt 33 = 100001 = 00001 = 1, etc //cazul incremental de ce? se poate si random....write pointer ia valoari random (unsigned$random%32 ca sa fie valori 0-31), pozitive //(WR_ORDER) - variabila , in case..si facem 3 cazuri..INCREENTAL (temp++), decremental(temp2--), random($unsigned random temp1%32 etc) //static temp2 = 31
  parameter RD_ORDER = 1;
  parameter WR_ORDER = 0; //0 - i, 1 - rand, 2 - d
  parameter TEST_NAME;
  parameter SEED_VAL = 555;

  int tests_passed = 0;
  int tests_failed = 0;
  int total_tests = 0;

  int seed = SEED_VAL;
  instruction_t iw_reg_test [0:31];

  initial begin //timpul 0 al simularii se executa
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU DON'T ***");
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
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    for (int i = 0; i < 32; i++)
    begin
      iw_reg_test[i] = '{opc:ZERO,default:0};
    end
    $display("\nWriting values to register stack...");
    //@(posedge clk) load_en = 1'b1;  
    //repeat (3) begin - cod original
    repeat (WR_NR) begin //modificare 11.03.2024 
      @(posedge clk) begin
        randomize_transaction;   
        save_test_data;
    end
    @(negedge clk) print_transaction;
      
    end
    save_test_data;
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin - cod original
    for (int i=0; i<=RD_NR; i++) begin //modificare 11.02.2024
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) 
        case (RD_ORDER)
          0: read_pointer = i;
          1: read_pointer = $unsigned($random)%32;
          2: read_pointer = 31 - (i % 32);
        endcase
      @(negedge clk) print_results;
      check_results;
    end

    @(posedge clk);
    final_report;
    tests_report;

  
    
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU  DON'T ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end


  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
  
    static int temp = 0; //static - alocata o singura data la apelul functiei //pt cazul decremental facem un temp_decrement = 31 si facem temp-- ...cand se ajunge la 0, facem -- => -1 care e 111111 = ultimii 5 biti = 31, ia de la capat
    static int temp2 = 31;

    operand_a     <= $random(seed)%16;                 // between -15 and 15 ..random genereaza un nr pe 32 biti, vendor - producator tool -2G....+2G
    operand_b     <= $unsigned($random)%16;            // between 0 and 15 //converteste nr negative la pozitive 
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    case (WR_ORDER) 
      0: write_pointer <= temp++;
      1: write_pointer <= $unsigned($random)%32;
      2: write_pointer <= temp2--;
    endcase
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

  function void save_test_data;
    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, 0};
    $display("Saving test register...");
    $display("Write pointer: %0d", write_pointer);
    $display("Opcode=  %0d", iw_reg_test[write_pointer].opc);
    $display("Operand_a: %0d", iw_reg_test[write_pointer].op_a);
    $display("Operand_b: %0d", iw_reg_test[write_pointer].op_b);
  endfunction: save_test_data

  function check_results;
  //calculam si aici rezultatul si comparam cu cel primit de la DUT
  //actual instr_word.result, declaram variabila locala exp_result
  //din instr lusm op a, op b, opcode si mai facem calculul o data
  //la final un if separat care trebuie sa faca comparatie intre rezultat comparat aici si rezultatul primit
  //trebuie sa verificam aici ca write_pointer sa fie ok si operanzii cititi bine 
  
  operand_result expected_result;

  static bit has_error = 0;

      if (iw_reg_test[read_pointer].opc === ZERO) 
        expected_result = 0;
      else if (iw_reg_test[read_pointer].opc === PASSA)
        expected_result = iw_reg_test[read_pointer].op_a;
      else if (iw_reg_test[read_pointer].opc === PASSB)
        expected_result = iw_reg_test[read_pointer].op_b;
      else if (iw_reg_test[read_pointer].opc === ADD)
        expected_result = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
      else if (iw_reg_test[read_pointer].opc === SUB)
        expected_result = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
      else if (iw_reg_test[read_pointer].opc === MULT)
        expected_result = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
      else if (iw_reg_test[read_pointer].opc === DIV) begin
        if(iw_reg_test[read_pointer].op_b === 0)
          expected_result = 0;
        else
          expected_result = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b; 
      end
      else if (iw_reg_test[read_pointer].opc === MOD) begin
          if(iw_reg_test[read_pointer].op_b === 0)
            expected_result = 0;
          else
            expected_result = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
      end

      $display("\nCheck Results:");
      $display("  read_pointer = %0d", read_pointer);
      $display("  opcode = %0d (%s)", iw_reg_test[read_pointer].opc, iw_reg_test[read_pointer].opc.name);
      $display("  operand_a = %0d",   iw_reg_test[read_pointer].op_a);
      $display("  operand_b = %0d", iw_reg_test[read_pointer].op_b);

  $display("Actual result DUT = %0d\n", instruction_word.result);
  $display("Expected result  = %0d\n", expected_result);
  
  if(iw_reg_test[read_pointer].opc !== instruction_word.opc) begin
      $display("The opcode is incorrect!");
      has_error = 1;
  end
  else
      $display("The opcode is correct!");

   if(iw_reg_test[read_pointer].op_a !== instruction_word.op_a) begin
      $display("Operand_a is incorrect!");
      has_error = 1;
   end
  else
      $display("Operand_a is correct!");
  
    if(iw_reg_test[read_pointer].op_b !== instruction_word.op_b) begin
      $display("Operand_b is incorrect!");
      has_error = 1;
    end
  else
      $display("Operand_b is correct!");

   if(expected_result !== instruction_word.result) begin
      $display("The result is incorrect!");
      has_error = 1;
   end
  else 
      $display("The result is correct!");
    
  total_tests++;

  if(has_error) begin
      tests_failed++;
      has_error = 0;
  end
  else
      tests_passed++;
  endfunction: check_results

function final_report;
  $display("\n******************************************************");
  $display(" *** There is a total of",RD_NR + 1," values to read ***");
  $display(" *** and",WR_NR," values to write. ***");
  $display(" *** Total tests :", total_tests," *** ");
  $display(" *** Passed values:",tests_passed," *** ");
  $display(" *** Failed values:",tests_failed," *** ");
  $display(" ******************************************************");

  if(tests_passed + tests_failed != total_tests)
    $display("ATTENTION! The number of passed and failed values does not match the number of values! ");

endfunction: final_report

function tests_report;
  
  int fd;
  fd = $fopen("../reports/regression_status.txt", "a");
  if(tests_failed == 0)
    $fdisplay(fd, "%s: PASSED", TEST_NAME);
  else
    $fdisplay(fd, "%s: FAILED", TEST_NAME);
  $fclose(fd);

endfunction: tests_report


endmodule : instr_register_test



