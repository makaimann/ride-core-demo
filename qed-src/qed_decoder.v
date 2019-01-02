// decoder for RISCV
// only supports a subset of R,I,S type instructions see riscv-spec-v2.1.pdf
// used along with strict input constraints to ifu_qed_instruction (specified for the formal tool)

module qed_decoder (/*AUTOARG*/
   // Outputs
   is_lw, is_sw,is_aluimm,is_alureg, rd, rs1, rs2, opcode, simm12, funct3, funct7,
   imm5,simm7, shamt,
   // Inputs
   ifu_qed_instruction
   );

                         
//   input [32:0]  ifu_qed_instruction; // instruction
   input  [31:0] ifu_qed_instruction;
   wire   [31:0] instruction;
   assign instruction = ifu_qed_instruction;
   
   output [4:0]  rd;
   output [4:0]  rs1;
   output [4:0]  rs2;
   output [6:0]  opcode;
   output [11:0] simm12;  // signed imm for I type or instructions using rd, rs1 only like LW 
   output [2:0] funct3;
   output [6:0] funct7;
   output [4:0] imm5;  // lower order imm bits for S type instruction
   output [6:0] simm7; // higher order bits (including sign bits) of imm operand for S type instruction
   output [4:0] shamt; // shift amount for immediate shift operations
   
  	
   // determine which format to use
   output 	is_lw;
   output 	is_sw;
   output 	is_aluimm;
   output 	is_alureg; // includes mult instructions

   // wire 	 LW;
   // wire 	 SW;

   // wire 	 ADD;      
   // wire 	 AND;      
   // wire 	 OR;      
   // wire 	 XOR;      
   // wire 	 SUB;      
   // wire 	 ADDI;     
   // wire 	 MUL;     
   // wire 	 MULH;     
   // wire 	 MULHU;     

   // op, for all formats
   assign opcode = instruction[6:0];
   assign rd = instruction[11:7];
   assign rs1 = instruction[19:15];
   assign rs2 = instruction[24:20];
   assign simm12 = instruction[31:20];
   assign simm7 = instruction[31:25];
   assign imm5 = instruction[11:7];
   assign shamt = instruction[24:20];
   assign funct3 = instruction[14:12];
   assign funct7 = instruction[31:25];

   // these constraints taken from riscv-spec-v2.1.pdf (pg. 54)
   assign is_lw = (opcode == 7'b0000011) && (funct3 == 3'b010);
   assign is_sw = (opcode == 7'b0100011) && (funct3 == 3'b010);
   assign is_alureg = (opcode == 7'b0110011);
   assign is_aluimm = (opcode == 7'b0010011);
        
endmodule // qed_decoder


