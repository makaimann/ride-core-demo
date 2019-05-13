`include "define.v"
`include "constants.vh"

module top
  (
//   input 	    CLK_P,
//   input 	    CLK_N,
//   input 	    RST_X_IN,
//   output 	    TXD,
//   input 	    RXD,
//   output reg [7:0] LED
   input clk,
// EDIT: make instruction a top-level input
   input [`INSN_LEN-1:0] instruction,
   input reset_x
   );

   //Active Low SW
//   wire 	    clk;
//   wire 	    reset_x;

   (* keep *)
   wire [`ADDR_LEN-1:0] pc;
   (* keep *)
   wire [4*`INSN_LEN-1:0] idata;
   (* keep *)
   wire [8:0] 		  imem_addr;
   (* keep *)
   wire [`DATA_LEN-1:0]   dmem_data;
   (* keep *)
   wire [`DATA_LEN-1:0]   dmem_wdata;
   (* keep *)
   wire [`ADDR_LEN-1:0]   dmem_addr;
   (* keep *)
   wire 		  dmem_we;
   (* keep *)
   wire [`DATA_LEN-1:0]   dmem_wdata_core;
   (* keep *)
   wire [`ADDR_LEN-1:0]   dmem_addr_core;
   (* keep *)
   wire 		  dmem_we_core;

   wire 		  utx_we;
   wire 		  finish_we;
   wire 		  ready_tx;
   wire 		  loaded;
   
   reg 			  prog_loading;
   wire [4*`INSN_LEN-1:0] prog_loaddata = 0;
   wire [`ADDR_LEN-1:0]   prog_loadaddr = 0;
   wire 		  prog_dmem_we = 0;
   wire 		  prog_imem_we = 0;

   // EDIT: Use the inst_constraint module to constrain instruction to be
   //       a valid instruction from the ISA
   (* keep *)
   wire [6:0] opcode;
   (* keep *)
   wire [4:0] rd;
   (* keep *)
   wire [4:0] rs1;
   (* keep *)
   wire [4:0] rs2;
   assign opcode = instruction[6:0];
   assign rd = instruction[11:7];
   assign rs1 = instruction[19:15];
   assign rs2 = instruction[24:20];
   inst_constraint inst_constraint0(.clk(clk),
                                    .instruction(instruction));
   // EDIT END
/*   
   assign utx_we = (dmem_we_core && (dmem_addr_core == 32'h0)) ? 1'b1 : 1'b0;
   assign finish_we = (dmem_we_core && (dmem_addr_core == 32'h8)) ? 1'b1 : 1'b0;
   
   always @ (posedge clk) begin
      if (!reset_x) begin
	 LED <= 0;
      end else if (utx_we) begin
	 LED <= {LED[7], dmem_wdata[6:0]};
      end else if (finish_we) begin
	 LED <= {1'b1, LED[6:0]};
      end
   end
*/
   always @ (posedge clk) begin
      if (!reset_x) begin
	 prog_loading <= 1'b1;
      end else begin
	 prog_loading <= 0;
      end
   end
/*   
   GEN_MMCM_DS genmmcmds
     (
      .CLK_P(CLK_P), 
      .CLK_N(CLK_N), 
      .RST_X_I(~RST_X_IN), 
      .CLK_O(clk), 
      .RST_X_O(reset_x)
      );
*/
   // EDIT: wire up the instruction to the new inst1 port
   pipeline pipe
     (
      .inst1(instruction),
      .clk(clk),
      .reset(~reset_x | prog_loading),
      .pc(pc),
      .idata(idata),
      .dmem_wdata(dmem_wdata_core),
      .dmem_addr(dmem_addr_core),
      .dmem_we(dmem_we_core),
      .dmem_data(dmem_data)
      );

   assign dmem_addr = prog_loading ? prog_loadaddr : dmem_addr_core;
   assign dmem_we = prog_loading ? prog_dmem_we : dmem_we_core;
   assign dmem_wdata = prog_loading ? prog_loaddata[127:96] : dmem_wdata_core;
   dmem datamemory(
		   .clk(clk),
		   .addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}),
		   .wdata(dmem_wdata),
		   .we(dmem_we),
		   .rdata(dmem_data)
		   );

   assign imem_addr = prog_loading ? prog_loadaddr[12:4] : pc[12:4];
   imem_ld instmemory(
		      .clk(~clk),
		      .addr(imem_addr),
		      .rdata(idata),
		      .wdata(prog_loaddata),
		      .we(prog_imem_we)
		      );

`ifdef FORMAL
   reg [3:0] state_counter = 0;

   always @(posedge clk) begin
      state_counter = state_counter + 1;
   end

   always @* begin
      assume ((state_counter < 3) == !reset_x);
      if (!reset_x) begin
         assume(opcode == 7'b1111111);
      end
   end
`endif
/*
   SingleUartTx sutx
     (
      .CLK(clk),
      .RST_X(reset_x),
      .TXD(TXD),
      .ERR(),
      .DT01(dmem_wdata[7:0]),
      .WE01(utx_we)
      );

   PLOADER loader
     (
      .CLK(clk),
      .RST_X(reset_x),
      .RXD(RXD),
      .ADDR(prog_loadaddr),
      .DATA(prog_loaddata),
      .WE_32(prog_dmem_we),
      .WE_128(prog_imem_we),
      .DONE(loaded)
      );
*/   
endmodule // top

   
