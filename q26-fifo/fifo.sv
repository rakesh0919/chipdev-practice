// Code your design here
`timescale 1ns/1ps

module model #(parameter
    DATA_WIDTH=8
) (
    input clk,
    input resetn,
    input [DATA_WIDTH-1:0] din,
    input wr,
    output logic [DATA_WIDTH-1:0] dout,
    output logic full,
    output logic empty
);


    localparam FIFO_DEPTH = 2;

    logic [DATA_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
    logic [$clog2(FIFO_DEPTH):0] wr_count;

    always @(posedge clk)
    begin
        if (!resetn)
        begin
            wr_count <= '0;
            fifo[0]  <= '0;
        end
        else if (wr)
        begin
            fifo[0] <= din;
            for (int i=1; i < FIFO_DEPTH; i++) begin
                fifo[i] <= fifo[i-1];
            end
            if (wr_count != FIFO_DEPTH)
                wr_count <= wr_count + 1;
        end
    end

    assign empty = (wr_count == 0);
    assign full  = (wr_count == FIFO_DEPTH);
    assign dout  = empty ? '0 : fifo[wr_count-1];

endmodule
