`include "qed.vh"

// Note: change all [32:0] wires to [31:0]
module qed (/*AUTOARG*/
   // Outputs
   qed_ifu_instruction, vld_out,
   // Inputs
   rst, ena,
   // vld_inst,    // vld_inst not needed as ifu_qed_instruction will be strictly limited to valid instructions and one NOP
     clk, //pipeline_empty  // pipeline empty not needed as we stall whenever pipeline is full 
    ifu_qed_instruction, exec_dup, stall_IF  // stall_IF will avoid state change in the i_cache
   );

   input rst;
   input ena;
//   input vld_inst;
   input clk;
   input exec_dup;
   input stall_IF;
   //input pipeline_empty;
   //input [32:0] ifu_qed_instruction;
   //output [32:0] qed_ifu_instruction;
   input [31:0] ifu_qed_instruction;
   output [31:0] qed_ifu_instruction;
   output        vld_out;
   
   
   wire [4:0] 	 rd;
   wire [4:0] 	 rs1;
   wire [4:0] 	 rs2;
   wire [6:0] 	 opcode;
   wire [11:0] 	 simm12;  // signed imm for I type or instructions using rd, rs1 only like LW 
   wire [2:0] 	 funct3;
   wire [6:0] 	 funct7;
   wire [4:0] 	 imm5;  // lower order imm bits for S type instruction
   wire [6:0] 	 simm7; // higher order bits (including sign bits) of imm operand for S type instruction
   wire [4:0] 	 shamt; // shift amount for immediate shift operations
   wire 	 is_lw;
   wire 	 is_sw;
   wire 	 is_aluimm;
   wire 	 is_alureg; // includes mult instructions

   wire [31:0]	 qed_instruction;
   wire [31:0] 	 qic_qimux_instruction;

   // temp
   // reg [31:0] 	 qed_reg;
   // wire [31:0] 	 qed_temp;
   // reg 		 vld_reg;
   // wire 	 vld_temp;
 		 
   
   // wire                 vld_out;
   // assign vld_out = (mode == `DUP_MODE);
   
   
   // qed_sm sm (/*AUTOINST*/
   //            // Outputs
   //            .mode                     (mode[2:0]),
   //            // Inputs
   //            .rst                      (rst),
   //            .clk                      (clk),
   //            .is_branch                (is_branch),
   //            .pipeline_empty           (pipeline_empty));

   qed_decoder dec (.ifu_qed_instruction(qic_qimux_instruction),
                    /*AUTOINST*/
                    // Outputs
                    .is_lw          (is_lw),
                    .is_sw          (is_sw),
		    .is_alureg      (is_alureg),
		    .is_aluimm      (is_aluimm),
                    .rd             (rd),
                    .rs1            (rs1),
                    .rs2            (rs2),
                    .simm12         (simm12),
		    .opcode         (opcode),
		    .funct7         (funct7),
		    .funct3         (funct3),
		    .imm5           (imm5),
		    .shamt          (shamt),
                    .simm7          (simm7)
		    );

   modify_instruction minst (
                             // Outputs
                             .qed_instruction   (qed_instruction),
                             // Inputs
                             .qic_qimux_instruction(qic_qimux_instruction),
                             .is_lw      (is_lw),
                             .is_sw      (is_sw),
                             .is_aluimm  (is_aluimm),
                             .is_alureg  (is_alureg),
                             .rd         (rd),
                             .rs1        (rs1),
                             .rs2        (rs2),
                             .simm12     (simm12),
			     .opcode     (opcode),
			     .funct3     (funct3),
			     .funct7     (funct7),
			     .imm5       (imm5),
			     .shamt      (shamt),
                             .simm7      (simm7));

   qed_instruction_mux imux (/*AUTOINST*/
                             // Outputs
                             .qed_ifu_instruction(qed_ifu_instruction),
			     //.qed_ifu_instruction(qed_temp),
                             // Inputs
                             .ifu_qed_instruction(ifu_qed_instruction),
                             .qed_instruction   (qed_instruction),
                            // .mode              (mode[2:0]),
			     .exec_dup          (exec_dup),
                             .ena               (ena));

   qed_i_cache qic (/*AUTOINST*/
                    // Outputs
                    .qic_qimux_instruction(qic_qimux_instruction),
		    .vld_out(vld_out),
		    //.vld_out(vld_temp),
                    // Inputs
                    .clk                (clk),
                    .rst                (rst),
//                    .vld_inst           (vld_inst),
//                    .mode               (mode[2:0]),
		    .exec_dup(exec_dup),
		    .IF_stall(stall_IF),
                    .ifu_qed_instruction(ifu_qed_instruction));

  // the below code is only used with simulating QED as a standalone module   
   // always @(posedge clk)
   //   begin
   // 	qed_reg <= qed_temp;
   // 	vld_reg <= vld_temp;
   //   end

   // assign qed_ifu_instruction = qed_reg;
   // assign vld_out = vld_reg;
   
   
endmodule // qed
