# Cover Properties

A cover property is just a property where the formal tool is looking for a trace that satisfies the constraint, rather than looking for a violation. It's good practice to include plenty of covers to check the behavior of the model and ensure that it hasn't been overconstrained by assumptions. You can think of covers as an alternative to simulations, where you do not need to provide input stimulus.

# Provided Covers

The file covers.txt provides several cover properties with descriptions. To speed up the checks, we don't include the reset procedure or initial state constraints, and use a cached version of the model (cached.btor), so we don't need to wait for the Verilog to be processed. 

From this directory, run it with: `CoSA --problems covers.txt`
As always, you can adjust the verbosity with `-v <1..4>`
