`timescale 1ns/1ps

module tb;
  reg clk, resetn, din, resetn_prev;
  wire dout;
  
  model uut(
    .clk(clk), .resetn(resetn),
    .din(din), .dout(dout)
  );
  
  always #5 clk = ~clk;

  task send_bit(input bit_val);
    din = bit_val;
    @(posedge clk); #1;
  endtask

  initial begin
    clk = 0; resetn = 0; din = 0;

    @(posedge clk); #1;
    @(posedge clk); #1;
    resetn = 1;
    @(posedge clk); #1;

    // ==============================
    // Test 1: Just 1010
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(0);

    if (dout !== 1)
      $error("Failed Test 1: dout should be 1 after 1010, got %b", dout);
    else if (uut.state !== 4)
      $error("Failed Test 1: should be in S1010, got state %0d", uut.state);
    else
      $display("Passed Test 1: 1010 detected correctly");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // Test 2: 101 then reset then 1
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);

    if (uut.state !== 3)
      $error("Failed Test 2: should be in S101 after 101, got %0d", uut.state);

    resetn = 0; @(posedge clk); #1;

    if (uut.state !== 0)
      $error("Failed Test 2: state should be S0 after reset, got %0d", uut.state);

    resetn = 1; @(posedge clk); #1;

    send_bit(1);

    if (uut.state !== 1)
      $error("Failed Test 2: should be S1 after fresh 1, got %0d", uut.state);
    else
      $display("Passed Test 2: reset clears state correctly");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // Test 3: Check state at 101
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);

    if (uut.state !== 3)
      $error("Failed Test 3: should be S101 after 101, got %0d", uut.state);
    else if (dout !== 0)
      $error("Failed Test 3: dout should still be 0 at 101");
    else
      $display("Passed Test 3: state correct at 101");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // Test 4: 1011
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);

    if (dout !== 0)
      $error("Failed Test 4: dout should be 0 after 1011, got %b", dout);
    else if (uut.state !== 1)
      $error("Failed Test 4: should be in S1 after 1011, got %0d", uut.state);
    else
      $display("Passed Test 4: 1011 correctly not detected");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // T5: All zeros to check state
    // ==============================
    send_bit(0);
    send_bit(0);
    send_bit(0);
    send_bit(0);
    send_bit(0);

    if (dout !== 0)
      $error("Failed Test 5: dout should be 0 for all zeros");
    else if (uut.state !== 0)
      $error("Failed Test 5: should stay in S0, got %0d", uut.state);
    else
      $display("Passed Test 5: all zeros stays in S0");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // T6: 001010 (pattern in middle of sequence)
    // ==============================
    send_bit(0);
    send_bit(0);
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(0);

    if (dout !== 1)
      $error("Failed Test 6: should detect 1010 mid-stream, got %b", dout);
    else
      $display("Passed Test 6: 1010 detected mid-stream");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // T7: 10101 overlapping sequence
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(0);

    if (dout !== 1)
      $error("Failed Test 7: first 1010 not detected");

    send_bit(1);

    if (uut.state !== 3)
      $error("Failed Test 7: should be S101 after overlap, got %0d", uut.state);
    else
      $display("Passed Test 7: overlapping sequence handled correctly");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // T8: Reset after detection
    // ==============================
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(0);

    if (dout !== 1)
      $error("Failed Test 8: 1010 not detected before reset");

    resetn = 0; @(posedge clk); #1;

    if (dout !== 0)
      $error("Failed Test 8: dout should clear after reset, got %b", dout);
    else if (uut.state !== 0)
      $error("Failed Test 8: state should be S0 after reset");
    else
      $display("Passed Test 8: reset clears after detection");

    $display("All tests passed!");
    $finish;
  end

  // ==============================
  // Assertions
  // ==============================

  always @(posedge clk) begin
    resetn_prev <= resetn;

    if (dout && uut.state !== 4)
      $error("Assertion error: dout high but not in S1010, state=%0d", uut.state);

    if (uut.state > 4)
      $error("Assertion error: illegal state %0d", uut.state);

    if (!resetn_prev && uut.state !== 0)
        $error("Assertion error: state should be S0 after reset, got %0d", uut.state);
  end

endmodule
