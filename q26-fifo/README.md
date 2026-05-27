Q26. Multi-Bit FIFO Testbench Verification exercise for ChipDev Q26. The FIFO holds 2 entries of 8 bits. There is no read signal as dout shows the oldest entry immediately. I focused on testing the boundary conditions.

## Tests

**Test 1 — First write (0xAA)**
One entry in, one slot still free. Checks dout updates immediately and full stays low.

**Test 2 — Second write (0xBB)**
Fills the FIFO. The check here is that dout still shows 0xAA and not 0xBB. Verifies the first in behavior is actually working.

**Test 3 — Overflow (0xCC)**
Writing to a full FIFO is defined as valid in the prompt. 0xAA should get pushed out and dout should now show 0xBB.

**Test 4 — wr=0**
Set din=0xDD with write disabled. Nothing should change. Checks that wr is actually gating the write logic.

---

## Assertions

Running every clock edge:

- full and empty never both high as they are mutually exclusive states
- dout is 0 when empty=1 to show that data is cleared when empty is true
- dout never goes X/Z when FIFO isn't empty
- full stays high when writing to a full FIFO

> The reset assertion was firing on the first clock edge before the design had a chance to respond. Added a one cycle delay after !resetn and that fixed it.

---

## Output
Passed Test 1
Passed Test 2
Passed Test 3
Passed Test 4
