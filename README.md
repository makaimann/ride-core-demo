# ride-core-demo
A tutorial for setting up Symbolic Quick Error Detection (SQED) using the open source, SMT-based model checker, CoSA.

As an example, we use the RIDECORE Out of Order RISC-V Processor. This tutorial shows how a
bug was discovered in the multiply decoder of this processor using SQED. It was fixed in this 
[commit](https://github.com/ridecore/ridecore/commit/200c6a663e01cb2231004bb2543e7ce8b1c92cca)

# Installing Dependencies
In the `install` directory, you will find a Dockerfile, a script for installing dependencies on Debian-based systems,
and a README with instructions for using either option.

# Navigating commits
Start the demo using `./start.sh` and move forward through commits using `./next.sh`. At each step, 
you can see the changed files with `git diff HEAD^`.

# What is SQED?
Symbolic Quick Error Detection (SQED) is a technique for logic bug detection and localization.
Quick Error Detection (QED) is an approach for identifying bugs (primarily in processors but it can also be used 
for other components) which transforms a set of original tests into QED checks. This involves splitting
the register file in half and using one half for the original instructions and the second half for a duplicated
sequence of instructions. Both the original and duplicated sequences execute the same instructions in the same order, 
but they are interleaved. After the original and duplicate instruction sequences complete, the two halves of the 
register file should match. Empirically, this approach can reduce the length of bug traces by up to 6 orders of 
magnitude when compared to traditional techniques.

_Symbolic_ QED is based on the observation that a Bounded Model Checker can _symbolically_ explore all instruction 
sequences (up to a bound). Notably, this gives us a way to verify a processor without writing tests, and without even 
providing any handwritten properties, instead relying only on this symbolic QED check. 
For a much more in depth introduction, see this [paper](https://arxiv.org/pdf/1711.06541.pdf).

# Setting up SQED
## Starting Point
Make sure to run `./start.sh`. This will detach the `HEAD` and start with only the buggy RIDECORE
source in the `ride-src` directory. These files were obtained from the ridecore 
[repository](https://github.com/ridecore/ridecore) master branch in `src/fpga` at commit hash 
[112a9bf24bf137344e89436c930c8d1220aaef60](https://github.com/ridecore/ridecore/commit/112a9bf24bf137344e89436c930c8d1220aaef60).
For each heading below, follow along by running `./next.sh`.

## Modify the RTL
To simplify verification, we will make some very minimal changes to the RTL and prepare it to be
read into CoSA using the Yosys frontend to read the Verilog/SystemVerilog source files.

* In topsim.v: Add the `(* keep *)` attribute to wires that we don't want Yosys to clean up
  * If a signal is not contributing to driving a primary output, Yosys will remove it.
  * This is basically a "Cone of Influence" reduction given the outputs.
  * In general this can be very helpful for verification, but for a model like this without
    any primary outputs, it requires this extra step or Yosys will remove most of the circuit.
* In pipeline.v: Turn the ride-core into a 1-wide fetch instead of a 2-wide fetch
  * The ride-core is capable of reading two instructions in per clock cycle
  * We hardcode the second instruction fetch signal to be invalid
  * And set the second instruciton to always be zeros
  * This change is not necessary but it speeds up verification, and makes the counterexample easier to read
* In pipeline_if.v: Disable branch prediction (always guess branch will not be taken)
  * Manually cut and assign the `predict_cond` signal to zero
  * Again, this is not necessary but speeds up verification
* In dmem.v: Shrink the data memory
  * This is also not necessary but helps performance, and doesn't affect the SQED property
  
## Add QED Module
First, we add the QED module RTL. This contains all of the logic for duplicating instruction sequences.
In the file inst_constraint.sv, we have encoded the RIDECORE's instruction set. We need this to constrain
the instruction to be a valid instruction, otherwise CoSA could find spurious bugs by using bogus instructions.

## Wire up QED Module

There are a couple changes which need to be made in the RIDECORE source RTL:

* pipeline.v: Instantiate the QED module in the pipeline
* pipeline.v: Add logic for tracking the number of committed instructions
  * This step is specific to each processor architecture
  * We simply need to know when the number of committed original and duplicated instructions are the same.
* pipeline.v, topsim.v: Disconnect the instruction from the instruction fetch, and make it a primary input
  * This is primarily for performance, as we're only looking for bugs after the instruction fetch stage.
* topsim.v: Instantiate `inst_constraint` to constrain the otherwise free input instruction signal to be
  a valid RISC-V instruction.

Important Note: CoSA will treat undriven signals as "free" signals which can vary over time. Notice that the
`qed_exec_dup` signal we added to pipeline.v is free. In other words, CoSA can choose when to interleave
original and duplicate instructions. However, CoSA does this by creating a new state element with Yosys, so
it's **very important** to avoid overconstraining the model, which can be easy to do with commands such as
`default_initial_value` which sets the initial value of state elements.
A good rule of thumb is that **any signal that you're making assumptions on (e.g. assuming that the instruction 
is from the RIDECORE ISA), should be a primary input.**

## Add CoSA configuration files

We create a directory named `cosa` and add four files to set-up the SQED problem with CoSA:

* ridecore.vlist: A list of Verilog/SystemVerilog source files.
* problem.txt: In problem files, you can set default configurations and define different problems for CoSA to run
  * In this file we use several commands, some notable ones are the following:
    * `model_file`: lists the files which define the system
    * `clock_behaviors`: toggle the clock at a certain frequency (relative to some global clock)
      * Note: abstracting the clock (`abstract_clock: True` and no `clock_behaviors`) can often speed up verification, but we need an "explicit" clock for this processor because there is negedge clock behavior.
    * `vcd`: sets whether to generate vcd for counterexample
    * `bmc_length`: what bound to check up to
    * `precondition`: Don't start checking the property until this condition holds. Here, we wait until the `reset_done` signal is true
    * `no_arrays`: When true, this uses Yosys to blast memories to registers and create decoder logic. This means that the SMT encoding will not use the theory of arrays but instead a collection of bitvector variables. For this particular problem, that is faster.
    * `default_initial_value`: Set every flop which doesn't already have an initial value to the supplied value (0 or 1) in the initial state.
* property.txt: Here we describe the QED property -- that once the same number of original and duplicate instructions execute,
the two halves of the register file should match. I.e. reg1 == reg17 and so on.
* reset_procedure.ets: This Explicit Transition System (ETS) file creates a "Synchronous System" state machine that is instantiated in parallel and constrains the model. In this case, we're using it to toggle the reset signal
  * The simple syntax just defines four states {I, S1, S2, S3}, assigns signals in each state, and defines transitions between the states. The first state in the list of transitions is always the initial state
  * You can also define new signals in this file, just by using them in the same format (example: `reset_done`)
  
You can run CoSA on this problem file with: `CoSA --problems ./cosa/problem.txt`.

You're welcome to increase the verbosity level of CoSA using the flag: `-v <1..4>`.

It takes about 10 minutes to find the bug. CoSA will print a minimal trace to the terminal, and dump more information to a vcd file. If you look at the opcode of the instruction in the counter-example, you will see a few multiplies, which trigger the bug. You can see from `inst_constraint.sv` that the multiply opcode is `0110011` (decimal: `51`). You will see that `pipe.num_orig_insts == pipe.num_dup_insts` at the end of the trace, but the register file (`pipe.aregfile.regfile.mem`) is not QED consistent.

## Fix the bug
The last commit simply applies the bug fix that was implemented in the actual RIDECORE code. If you run CoSA again, it will not find a bug at bound 24 anymore. 
