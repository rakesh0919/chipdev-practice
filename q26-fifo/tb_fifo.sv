`timescale 1ns/1ps

module tb_fifo;
  
  reg clk, resetn, wr;
  reg [7:0] din;
  wire [7:0] dout; 
  wire full, empty;
  
  model uut(
    .clk(clk), .resetn(resetn),
    .wr(wr), .din(din), .dout(dout),
    .full(full), .empty(empty)
  );
  
  always #5 clk = ~clk;
  
  initial begin
    clk = 0;
    resetn = 0; 
    wr = 0; din = 0;
    
    @(posedge clk); #1; 
    
    //release reset
    resetn = 1;
    @(posedge clk); #1;
    
    // ==============================
    //Test 1: Write A
    // ==============================
    
    wr = 1; din = 8'hAA;
    @(posedge clk); #1; 
    wr = 0; 
    
    if (dout != 8'hAA)
      $error("Failed Test 1: dout should be AA, it was %h", dout);
    else if (empty !== 0)
      $error("Failed Test 1: empty should be 0 after write, got %b", empty);
    else if (full !== 0)
      $error("Failed Test 1: full should be 0 with 1 entry, got %b", full);
    else
      $display("Passed Test 1");
    
    // ==============================
    //Test 2: Write B
    // ==============================
    
    wr = 1; din = 8'hBB;
    @(posedge clk); #1; 
    wr = 0; 
    
    if (dout != 8'hAA)
      $error("Failed Test 2: dout should be AA, it was %h", dout);
    else if (empty !== 0)
      $error("Failed Test 2: empty should be 0 after write, got %b", empty);
    else if (full !== 1)
      $error("Failed Test 2: full should be 0 with 2 entries, got %b", full);
    else
      $display("Passed Test 2");
    
    // ==============================
    //Test 3: Write C (Overflow)
    // ==============================
    
    wr = 1; din = 8'hCC;
    @(posedge clk); #1; 
    wr = 0; 
    
    if (dout != 8'hBB)
      $error("Failed Test 3: dout should be BB, it was %h", dout);
    else if (empty !== 0)
      $error("Failed Test 3: empty should be 0 after write, got %b", empty);
    else if (full !== 1)
      $error("Failed Test 3: full should be 0 with 2 entries, got %b", full);
    else
      $display("Passed Test 3");
    
    
    // ==============================
    //Test 4: Write with wr set to 0
    // ==============================
    
    din = 8'hDD;
    @(posedge clk); #1; 
    
    if (dout != 8'hBB)
      $error("Failed Test 4: dout should be BB, it was %h", dout);
    else if (empty !== 0)
      $error("Failed Test 4: empty should be 0 after write, got %b", empty);
    else if (full !== 1)
      $error("Failed Test 4: full should be 0 with 2 entries, got %b", full);
    else
      $display("Passed Test 4");
    
  end
  
  // ==============================
  //Assertions
  // ==============================
  
  always @(posedge clk) begin
    // 1. mutual exclusion
    if (full && empty)
      $error("Assertion error: full and empty both high");
    
    // 2. empty implies dout=0
    if (empty && dout !== 0)
        $error("Assertion error: dout should be 0 when empty");
    
    // 3. full stays high on write to full FIFO    
    if (full && wr && full !== 1)
        $error("Assertion error: full dropped during write to full FIFO");
    
    // 4. dout never undefined when not empty
    if (!empty && (dout === 8'hx || dout === 8'hz))
        $error("Assertion error: dout undefined when FIFO not empty");
    
    // 5. reset state
    if (!resetn) begin
      @(posedge clk); #1;  // wait one cycle to allow 
        if (empty !== 1)
            $error("Assertion error: empty should be 1 during reset");
        if (full !== 0)
            $error("Assertion error: full should be 0 during reset");
        if (dout !== 0)
            $error("Assertion error: dout should be 0 during reset");
    end
end
    
  
endmodule
