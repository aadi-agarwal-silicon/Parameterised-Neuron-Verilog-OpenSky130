`timescale 1ns / 1ps
`timescale 1ns/1ps

module neuron_tb;

parameter N = 4;
parameter WIDTH = 8;
parameter ACC_WIDTH = 32;

reg clk;
reg rst;
reg start;

reg signed [N*WIDTH-1:0] x_bus;
reg signed [N*WIDTH-1:0] w_bus;

reg signed [ACC_WIDTH-1:0] bias;

wire signed [ACC_WIDTH-1:0] result;
wire done;

neuron #(
    .N(N),
    .WIDTH(WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .x_bus(x_bus),
    .w_bus(w_bus),
    .bias(bias),
    .result(result),
    .done(done)
);


// Clock generation
always #5 clk = ~clk;


// Test sequence
initial begin

    //--------------------------------
    // Initialize signals
    //--------------------------------
    clk   = 0;
    rst   = 1;
    start = 0;

    x_bus = 0;
    w_bus = 0;
    bias  = 0;

    //--------------------------------
    // Reset
    //--------------------------------
    #20;
    rst = 0;

    //--------------------------------
    // Load Inputs
    //--------------------------------

    // x_bus = {x3,x2,x1,x0}
    x_bus = {
                8'sd1,
                8'sd3,
                -8'sd2,
                8'sd1
            };

    // w_bus = {w3,w2,w1,w0}
    w_bus = {
                -8'sd3,
               -8'sd1,
                -8'sd3,
                8'sd1
            };

    bias = 32'sd1;

    //--------------------------------
    // Start computation
    //--------------------------------
    #10;
    start = 1;

    #10;
    start = 0;

    //--------------------------------
    // Wait for completion
    //--------------------------------
    wait(done);

    $display("-----------------------------------");
    $display("Expected Result : 2");
    $display("Neuron Result   : %0d", result);

    if(result == 2)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    $display("-----------------------------------");

    #20;
    $finish;

end

endmodule
