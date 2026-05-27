# Q30. 2-Read 1-Write Register File Testbench

 The design is a 32 entry 16 bit wide register file with one write port and two read ports. I focused on testing the collision cases since that is where bugs tend to hide.

## Tests

**Test 1: Basic read/write roundtrip**
Write 0xAAAA to address 5 then read it back on port 1. Basic Sanity Check

**Test 2: Both ports reading different addresses**
Write two different values to two different addresses then read both simultaneously. Checks that the read ports can work indepedentyl

**Test 3: Read collision same address**
Both read ports pointed at the same address. The design should set collision high and zero out both outputs. Verifies the mutual exclusion logic is working.

**Test 4: Write/read collision**
Write and read the same address at the same time. Same result as Test 3 — collision fires, outputs go to zero.

**Test 5: Write and read both ports simultaneously**
Write to address 3 while reading addresses 1 and 2 at the same time. All three addresses are different so no collision should fire and both reads should return the correct values.

**Test 6: Reset clears outputs**
Write 0xFFFF to an address, read it back to confirm dout1 shows the value, then hit reset. Checks that dout1 and dout2 go to zero after reset. Note: Icarus Verilog does not reliably support resetting memory arrays inside always blocks so this test checks output clearing rather than memory clearing directly.

**Test 7: Address 31 boundary**
Write and read back from the highest valid address. Checks that the 5 bit address lines work correctly at the boundary.

---

## Assertions

Running every clock edge:

- when collision is high both dout1 and dout2 must be zero, if either output is nonzero while collision is high something is broken
- one cycle after reset is asserted, all outputs must be zero

> The reset assertion had the same timing issue as Q15 — it was firing on the same clock edge that resetn went low before the design responded. Fixed it with resetn_prev the same way.

---

## Output
- Passed Test 1: basic read/write roundtrip correct
- Passed Test 2: both ports different addresses correct
- Passed Test 3: read collision on same address correct
- Passed Test 4: write/read collision correct
- Passed Test 5: write and read both ports simultaneously correct
- Passed Test 6: reset clears outputs correctly
- Passed Test 7: address 31 boundary correct
- All tests passed!
- testbench.sv:186: $finish called at 236000 (1ps)
