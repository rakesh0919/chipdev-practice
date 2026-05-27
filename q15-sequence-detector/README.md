# Q15 — Sequence Detector Testbench

Verification exercise for ChipDev Q15. The design is a sequence detector that outputs dout=1 when it sees the pattern 1010 in a stream of bits. It has 5 states: S0, S1, S10, S101, and S1010. I focused on testing not just the happy path but also reset behavior, overlapping sequences, and sequences that almost match.

## Tests

**Test 1: Just 1010**
The basic case. Feed in 1010 and check dout goes high and state lands in S1010.

**Test 2: 101 then reset then 1**
Send 101 to get into S101, then hit reset mid sequence. Checks that state goes back to S0 and a fresh stream starting with 1 correctly lands in S1.

**Test 3: Check state at 101**
Verifies the internal state is S101 after seeing 101 and that dout is still 0 since the sequence isn't complete yet.

**Test 4: 1011**
A sequence that starts like 1010 but breaks at the end. dout should never fire and state should end up in S1 since the last bit was 1.

**Test 5: All zeros**
Feed 00000 and check the state stays in S0 the whole time. dout should never go high.

**Test 6: 001010**
The pattern shows up in the middle of a stream. Checks the detector still catches it regardless of what came before.

**Test 7: 10101 overlapping**
After detecting 1010, feeding a 1 should put the state in S101 not back to S0. Tests that the overlap behavior is handled correctly.

**Test 8: Reset after detection**
Detect 1010, then immediately hit reset. Checks that dout clears and state goes back to S0.

---

## Assertions

Running every clock edge:

- dout is only ever high when state is S1010, if it fires in any other state something is broken
- state never goes above 4 since there are only 5 valid states
- one cycle after reset is asserted, state must be S0

> The reset assertion was originally firing on the same clock edge that resetn went low, before the design had a chance to respond. Fixed it by registering resetn into resetn_prev and checking state one cycle later instead.

---

## Output

Passed Test 1: 1010 detected correctly
Passed Test 2: reset clears state correctly
Passed Test 3: state correct at 101
Passed Test 4: 1011 correctly not detected
Passed Test 5: all zeros stays in S0
Passed Test 6: 1010 detected mid-stream
Passed Test 7: overlapping sequence handled correctly
Passed Test 8: reset clears after detection
All tests passed!
testbench.sv:179: $finish called at 546000 (1ps)
