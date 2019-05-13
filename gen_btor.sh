# NO ARRAYS
# yosys -l yosys.log -p "verific -vlog-incdir ./ride-src/; verific -vlog-incdir ./qed-src/; read -formal ./ride-src/topsim.v ./ride-src/alloc_issue_ino.v ./ride-src/search_be.v ./ride-src/srcsel.v ./ride-src/alu_ops.vh ./ride-src/arf.v ./ride-src/ram_sync.v ./ride-src/ram_sync_nolatch.v ./ride-src/brimm_gen.v ./ride-src/constants.vh ./ride-src/decoder.v ./ride-src/dmem.v ./ride-src/exunit_alu.v ./ride-src/exunit_branch.v ./ride-src/exunit_ldst.v ./ride-src/exunit_mul.v ./ride-src/imem.v ./ride-src/imm_gen.v ./ride-src/pipeline_if.v ./ride-src/gshare.v ./ride-src/pipeline.v ./ride-src/oldest_finder.v ./ride-src/btb.v ./ride-src/prioenc.v ./ride-src/mpft.v ./ride-src/reorderbuf.v ./ride-src/rrf_freelistmanager.v ./ride-src/rrf.v ./ride-src/rs_alu.v ./ride-src/rs_branch.v ./ride-src/rs_ldst.v ./ride-src/rs_mul.v ./ride-src/rs_reqgen.v ./ride-src/rv32_opcodes.vh ./ride-src/src_manager.v ./ride-src/srcopr_manager.v ./ride-src/storebuf.v ./ride-src/tag_generator.v ./ride-src/dualport_ram.v ./ride-src/alu.v ./ride-src/multiplier.v ./qed-src/inst_constraint.sv ./qed-src/modify_instruction.v ./qed-src/qed_decoder.v ./qed-src/qed_i_cache.v ./qed-src/qed_instruction_mux.v ./qed-src/qed.v ./qed-src/qed.vh; prep -top top; hierarchy -check; chformal -assume -early; memory; flatten; zinit -singleton; setundef -undriven -anyseq; write_btor ridecore.btor"
# yosys -l yosys.log -p "read_verilog -formal ./ride-src/topsim.v ./ride-src/alloc_issue_ino.v ./ride-src/search_be.v ./ride-src/srcsel.v ./ride-src/alu_ops.vh ./ride-src/arf.v ./ride-src/ram_sync.v ./ride-src/ram_sync_nolatch.v ./ride-src/brimm_gen.v ./ride-src/constants.vh ./ride-src/decoder.v ./ride-src/dmem.v ./ride-src/exunit_alu.v ./ride-src/exunit_branch.v ./ride-src/exunit_ldst.v ./ride-src/exunit_mul.v ./ride-src/imem.v ./ride-src/imm_gen.v ./ride-src/pipeline_if.v ./ride-src/gshare.v ./ride-src/pipeline.v ./ride-src/oldest_finder.v ./ride-src/btb.v ./ride-src/prioenc.v ./ride-src/mpft.v ./ride-src/reorderbuf.v ./ride-src/rrf_freelistmanager.v ./ride-src/rrf.v ./ride-src/rs_alu.v ./ride-src/rs_branch.v ./ride-src/rs_ldst.v ./ride-src/rs_mul.v ./ride-src/rs_reqgen.v ./ride-src/rv32_opcodes.vh ./ride-src/src_manager.v ./ride-src/srcopr_manager.v ./ride-src/storebuf.v ./ride-src/tag_generator.v ./ride-src/dualport_ram.v ./ride-src/alu.v ./ride-src/multiplier.v ./qed-src/inst_constraint.sv ./qed-src/modify_instruction.v ./qed-src/qed_decoder.v ./qed-src/qed_i_cache.v ./qed-src/qed_instruction_mux.v ./qed-src/qed.v ./qed-src/qed.vh; prep -top top; hierarchy -check; chformal -assume -early; memory; flatten; setundef -zero -init; setundef -undriven -anyseq; write_btor ridecore.btor"

# ARRAYS
yosys -l yosys.log -p "verific -vlog-incdir ./ride-src/; verific -vlog-incdir ./qed-src/; read -formal ./ride-src/topsim.v \
./ride-src/alloc_issue_ino.v \
./ride-src/search_be.v \
./ride-src/srcsel.v  \
./ride-src/alu_ops.vh \
./ride-src/arf.v \
./ride-src/ram_sync.v \
./ride-src/ram_sync_nolatch.v  \
./ride-src/brimm_gen.v \
./ride-src/constants.vh \
./ride-src/decoder.v \
./ride-src/dmem.v \
./ride-src/exunit_alu.v \
./ride-src/exunit_branch.v \
./ride-src/exunit_ldst.v \
./ride-src/exunit_mul.v \
./ride-src/imem.v \
./ride-src/imm_gen.v \
./ride-src/pipeline_if.v \
./ride-src/gshare.v \
./ride-src/pipeline.v \
./ride-src/oldest_finder.v \
./ride-src/btb.v \
./ride-src/prioenc.v \
./ride-src/mpft.v \
./ride-src/reorderbuf.v \
./ride-src/rrf_freelistmanager.v \
./ride-src/rrf.v \
./ride-src/rs_alu.v \
./ride-src/rs_branch.v \
./ride-src/rs_ldst.v \
./ride-src/rs_mul.v \
./ride-src/rs_reqgen.v \
./ride-src/rv32_opcodes.vh \
./ride-src/src_manager.v \
./ride-src/srcopr_manager.v \
./ride-src/storebuf.v \
./ride-src/tag_generator.v \
./ride-src/dualport_ram.v \
./ride-src/alu.v \
./ride-src/multiplier.v \
./qed-src/inst_constraint.sv \
./qed-src/modify_instruction.v \
./qed-src/qed_decoder.v \
./qed-src/qed_i_cache.v \
./qed-src/qed_instruction_mux.v \
./qed-src/qed.v \
./qed-src/qed.vh;
prep -top top; \
hierarchy -check; \
memory -nomap; \
flatten; \
chformal -assume -early; \
setundef -undriven -anyseq; \
zinit -singleton; \
write_btor ridecore-arrays.btor
"
