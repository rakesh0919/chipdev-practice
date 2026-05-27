// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb;
  reg clk, resetn, resetn_prev;
  reg [15:0] din;
  reg [4:0] wad1, rad1, rad2;
  reg wen1, ren1, ren2;
  wire [15:0] dout1, dout2;
  wire collision;

  model uut(
    .clk(clk), .resetn(resetn),
    .din(din), .wad1(wad1),
    .rad1(rad1), .rad2(rad2),
    .wen1(wen1), .ren1(ren1), .ren2(ren2),
    .dout1(dout1), .dout2(dout2),
    .collision(collision)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0; resetn = 0;
    wen1 = 0; ren1 = 0; ren2 = 0;
    din = 0; wad1 = 0; rad1 = 0; rad2 = 0;

    @(posedge clk); #1;
    resetn = 1;
    @(posedge clk); #1;

    // ==============================
    // Test 1: Basic read/write roundtrip
    // ==============================
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd5; din = 16'hAAAA;
    @(posedge clk); #1;

    wen1 = 0; ren1 = 1; ren2 = 0;
    rad1 = 5'd5;
    @(posedge clk); #1;

    if (dout1 !== 16'hAAAA)
      $error("Failed Test 1: dout1 should be AAAA, got %h", dout1);
    else if (dout2 !== 0)
      $error("Failed Test 1: dout2 should be 0, got %h", dout2);
    else if (collision !== 0)
      $error("Failed Test 1: collision should be 0, got %b", collision);
    else
      $display("Passed Test 1: basic read/write roundtrip correct");

    // ==============================
    // Test 2: Both ports different addresses
    // ==============================
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd3; din = 16'hBBBB;
    @(posedge clk); #1;

    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd7; din = 16'hCCCC;
    @(posedge clk); #1;

    wen1 = 0; ren1 = 1; ren2 = 1;
    rad1 = 5'd3; rad2 = 5'd7;
    @(posedge clk); #1;

    if (dout1 !== 16'hBBBB)
      $error("Failed Test 2: dout1 should be BBBB, got %h", dout1);
    else if (dout2 !== 16'hCCCC)
      $error("Failed Test 2: dout2 should be CCCC, got %h", dout2);
    else if (collision !== 0)
      $error("Failed Test 2: collision should be 0, got %b", collision);
    else
      $display("Passed Test 2: both ports different addresses correct");

    // reset before collision tests since stale memory could affect results
    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // Test 3: Read collision same address
    // ==============================
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd10; din = 16'hDDDD;
    @(posedge clk); #1;

    wen1 = 0; ren1 = 1; ren2 = 1;
    rad1 = 5'd10; rad2 = 5'd10;
    @(posedge clk); #1;

    if (collision !== 1)
      $error("Failed Test 3: collision should be 1 for same read address, got %b", collision);
    else if (dout1 !== 0)
      $error("Failed Test 3: dout1 should be 0 on collision, got %h", dout1);
    else if (dout2 !== 0)
      $error("Failed Test 3: dout2 should be 0 on collision, got %h", dout2);
    else
      $display("Passed Test 3: read collision on same address correct");

    // ==============================
    // Test 4: Write/read collision
    // ==============================
    wen1 = 1; ren1 = 1; ren2 = 0;
    wad1 = 5'd15; rad1 = 5'd15; din = 16'hEEEE;
    @(posedge clk); #1;

    if (collision !== 1)
      $error("Failed Test 4: collision should be 1 for write/read same address, got %b", collision);
    else if (dout1 !== 0)
      $error("Failed Test 4: dout1 should be 0 on collision, got %h", dout1);
    else if (dout2 !== 0)
      $error("Failed Test 4: dout2 should be 0 on collision, got %h", dout2);
    else
      $display("Passed Test 4: write/read collision correct");

    resetn = 0; @(posedge clk); #1; resetn = 1; @(posedge clk); #1;

    // ==============================
    // Test 5: Write + read both ports simultaneously
    // ==============================
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd1; din = 16'h1111;
    @(posedge clk); #1;

    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd2; din = 16'h2222;
    @(posedge clk); #1;

    // write to addr 3 while reading addr 1 and 2
    wen1 = 1; ren1 = 1; ren2 = 1;
    wad1 = 5'd3; din = 16'h3333;
    rad1 = 5'd1; rad2 = 5'd2;
    @(posedge clk); #1;

    if (dout1 !== 16'h1111)
      $error("Failed Test 5: dout1 should be 1111, got %h", dout1);
    else if (dout2 !== 16'h2222)
      $error("Failed Test 5: dout2 should be 2222, got %h", dout2);
    else if (collision !== 0)
      $error("Failed Test 5: collision should be 0, got %b", collision);
    else
      $display("Passed Test 5: write and read both ports simultaneously correct");

    // ==============================
    // Test 6: Reset clears outputs
    // ==============================

    // write ffff to address 8
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd8; din = 16'hFFFF;
    @(posedge clk); #1;

    // read it back to get ffff on dout1
    wen1 = 0; ren1 = 1; ren2 = 0;
    rad1 = 5'd8;
    @(posedge clk); #1;

    // now reset — dout1 should go to 0
    resetn = 0; @(posedge clk); #1;
    resetn = 1; @(posedge clk); #1;

    if (dout1 !== 0)
      $error("Failed Test 6: dout1 should be 0 after reset, got %h", dout1);
    else
      $display("Passed Test 6: reset clears outputs correctly");
    
    // ==============================
    // Test 7: Address 31 boundary
    // ==============================
    wen1 = 1; ren1 = 0; ren2 = 0;
    wad1 = 5'd31; din = 16'hABCD;
    @(posedge clk); #1;

    wen1 = 0; ren1 = 1; ren2 = 0;
    rad1 = 5'd31;
    @(posedge clk); #1;

    if (dout1 !== 16'hABCD)
      $error("Failed Test 7: dout1 should be ABCD at address 31, got %h", dout1);
    else if (collision !== 0)
      $error("Failed Test 7: collision should be 0, got %b", collision);
    else
      $display("Passed Test 7: address 31 boundary correct");

    $display("All tests passed!");
    $finish;
  end

  // ==============================
  // Assertions
  // ==============================

  always @(posedge clk) begin
    resetn_prev <= resetn;

    // when collision fires outputs must be zero
    if (collision && (dout1 !== 0 || dout2 !== 0))
      $error("Assertion error: collision high but outputs not zero, dout1=%h dout2=%h", dout1, dout2);

    // one cycle after reset everything should be cleared
    if (!resetn_prev && (dout1 !== 0 || dout2 !== 0 || collision !== 0))
      $error("Assertion error: outputs should be 0 after reset, dout1=%h dout2=%h collision=%b", dout1, dout2, collision);
  end

endmodule
