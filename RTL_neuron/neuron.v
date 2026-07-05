`timescale 1ns / 1ps
module neuron #(
    parameter N         = 4,
    parameter WIDTH     = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input rst,
    input start,

    input signed [N*WIDTH-1:0] x_bus,
    input signed [N*WIDTH-1:0] w_bus,

    input signed [ACC_WIDTH-1:0] bias,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg done
);

    //---------------------------------------
    // FSM States
    //---------------------------------------
    localparam IDLE     = 3'd0;
    localparam MAC      = 3'd1;
    localparam ADD_BIAS = 3'd2;
    localparam ACTIVATE = 3'd3;
    localparam FINISH   = 3'd4;

    reg [2:0] state;

    //---------------------------------------
    // Internal Registers
    //---------------------------------------
    reg [$clog2(N):0] index;

    reg signed [ACC_WIDTH-1:0] accumulator;

    //---------------------------------------
    // Current input and weight extraction
    //---------------------------------------
    wire signed [WIDTH-1:0] current_x;
    wire signed [WIDTH-1:0] current_w;

    assign current_x =
        x_bus[index*WIDTH +: WIDTH];

    assign current_w =
        w_bus[index*WIDTH +: WIDTH];

    //---------------------------------------
    // Multiplier Output
    //---------------------------------------
    wire signed [2*WIDTH-1:0] mult_out;

    assign mult_out = current_x * current_w;

    //---------------------------------------
    // Main FSM
    //---------------------------------------
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state       <= IDLE;
            index       <= 0;
            accumulator <= 0;
            result      <= 0;
            done        <= 0;
        end

        else
        begin
            case(state)

            //--------------------------------
            // IDLE
            //--------------------------------
            IDLE:
            begin
                done <= 0;

                if(start)
                begin
                    accumulator <= 0;
                    index <= 0;
                    state <= MAC;
                end
            end

            //--------------------------------
            // MAC State
            //--------------------------------
            MAC:
            begin
                accumulator <= accumulator + mult_out;

                if(index == N-1)
                    state <= ADD_BIAS;
                else
                    index <= index + 1;
            end

            //--------------------------------
            // Add Bias
            //--------------------------------
            ADD_BIAS:
            begin
                accumulator <= accumulator + bias;
                state <= ACTIVATE;
            end

            //--------------------------------
            // ReLU Activation
            //--------------------------------
            ACTIVATE:
            begin
                if(accumulator < 0)
                    result <= 0;
                else
                    result <= accumulator;

                state <= FINISH;
            end

            //--------------------------------
            // Finish State
            //--------------------------------
            FINISH:
            begin
                done <= 1;

                if(!start)
                    state <= IDLE;
            end

            default:
                state <= IDLE;

            endcase
        end
    end

endmodule
