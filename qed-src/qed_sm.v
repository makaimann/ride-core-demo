`include "qed.vh"
  
module qed_sm (// input
               rst,
               clk,
               is_branch,
               pipeline_empty,
               // output
               mode
               );

   input        rst;
   input        clk;
   input        is_branch;
   input        pipeline_empty;
   output [2:0] mode;
   reg    [2:0] mode_reg;
   //wire [2:0]  nxt_mode;
   // output [2:0] mode_sync;
   //output       mode_sync_ena;
   
   assign mode = mode_reg;
     
   always @(posedge clk)
     begin
        if (rst)
          begin
             mode_reg <= `ORIGINAL_MODE;
`ifdef QED_DEBUG
             $display("reset to ORIGINAL_MODE");
`endif
          end
        
        // CHECK
        if (mode_reg == `CHECK_MODE)
          begin
`ifdef QED_DEBUG
             $display("CHECK_MODE");
`endif
             mode_reg <= `ORIGINAL_MODE;
          end

        // ORIGINAL
        if (mode_reg == `ORIGINAL_MODE)
          begin
`ifdef QED_DEBUG
             $display("ORIGINAL_MODE");
`endif
             if (is_branch)
               begin
                  mode_reg <= `WAIT1_MODE;
               end
             else
               begin
                  mode_reg <= `ORIGINAL_MODE;
               end
          end

        // WAIT1
        if (mode_reg == `WAIT1_MODE)
          begin
`ifdef QED_DEBUG
             $display("WAIT1_MODE");
`endif
             if (pipeline_empty)
               begin
                  mode_reg <= `DUP_MODE;
               end
             else
               begin
                  mode_reg <= `WAIT1_MODE;
               end
          end
            
        // DUP
        if (mode_reg == `DUP_MODE)
          begin
`ifdef QED_DEBUG
             $display("DUP_MODE");
`endif
             if (is_branch)
               begin
                  mode_reg <= `WAIT2_MODE;
               end
             else
               begin
                  mode_reg <= `DUP_MODE;
               end
          end
        
        // WAIT2
        if (mode_reg == `WAIT2_MODE)
          begin
`ifdef QED_DEBUG
             $display("WAIT2_MODE");
`endif
             if (pipeline_empty)
               begin
                  mode_reg <= `CHECK_MODE;
               end
             else
               begin
                  mode_reg <= `WAIT2_MODE;
               end
          end
     end
   
endmodule // qed_sm
