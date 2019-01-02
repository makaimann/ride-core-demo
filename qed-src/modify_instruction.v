// use along with input constraints to the formal tool

module modify_instruction (qic_qimux_instruction,
                           is_lw,
                           is_sw,
                           is_aluimm,
			   is_alureg,

                           rd,
                           rs1,
                           rs2,
                           simm12,
			   opcode,
			   funct3,
			   funct7,
			   imm5,
			   shamt,
                           simm7,

                           qed_instruction);

   input [31:0] qic_qimux_instruction;
   wire [31:0]  instruction;
   assign instruction = qic_qimux_instruction;

   input [4:0] 	rd;
   input [4:0]  rs1;
   input [4:0]  rs2;
   input [6:0]  opcode;
   input [11:0] simm12;  // signed imm for I type or instructions using rd, rs1 only like LW 
   input [2:0] 	funct3;
   input [6:0] 	funct7;
   input [4:0] 	imm5;  // lower order imm bits for S type instruction
   input [6:0] 	simm7; // higher order bits (including sign bits) of imm operand for S type instruction
   input [4:0] 	shamt; // shift amount for immediate shift operations

   input 	is_lw;
   input 	is_sw;
   input 	is_aluimm;
   input 	is_alureg; // includes mult instructions

   output [31:0] qed_instruction;
   
   wire [31:0]   ins_lw;
   wire [31:0]   ins_sw;
   wire [31:0]   ins_alureg;
   wire [31:0]   ins_aluimm;

   wire [4:0]    new_rd;
   wire [4:0]    new_rs1;
   wire [4:0]    new_rs2;
   wire [11:0]   new_simm12;
   wire [6:0] 	 new_simm7;
  
   assign new_rd  = (rd  == 5'b00000) ? rd  : {1'b1, rd[3:0]};
   assign new_rs1 = (rs1 == 5'b00000) ? rs1 : {1'b1, rs1[3:0]};
   assign new_rs2 = (rs2 == 5'b00000) ? rs2 : {1'b1, rs2[3:0]};
   assign new_simm12 = {2'b01, simm12[9:0]};
   assign new_simm7 = {2'b01, simm7[4:0]};  // signed bit is always zero for lw,sw instructions
   
   
   assign ins_lw    = {new_simm12, 5'b0, funct3, new_rd, opcode};
   assign ins_sw    = {new_simm7, new_rs2, 5'b0, funct3, imm5, opcode};
   assign ins_aluimm = {simm12, new_rs1, funct3, new_rd, opcode};
   assign ins_alureg = {funct7, new_rs2, new_rs1, funct3, new_rd, opcode};
      

   assign qed_instruction = is_lw ? ins_lw : (is_sw ? ins_sw : (is_alureg ? ins_alureg : 
								(is_aluimm ? ins_aluimm : instruction)));
   
   
endmodule // modify_instruction

                           
